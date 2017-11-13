
function [CSI,A] = API_CSI_Generator( theta, tau, paths, ...
                            Nrx,ant_dist,samples, ...
                            fc,Nc,Delta_f,SNR, option)
                        
if nargin == 10 || (nargin == 11 && strcmp(option, 'non-smoothing'))
	%非相干情况，90*paths的矩阵，相当于有90个阵元(3*30)
    A = zeros(Nrx*Nc,paths); % 90 * paths
    X = zeros(Nrx*Nc,samples); % 90 * samples
    CSI = zeros(Nrx*Nc,samples); % 90 * samples
	
elseif nargin == 11 && strcmp(option, 'smoothing')  % 自己修该，原来是'non-smoothing'
    sizeSubArray = ceil(Nrx/2)*ceil(Nc/2); % 30
    A = zeros(sizeSubArray,paths); % 30 * paths 
    nSubArray = ceil(Nrx/2)*(Nc-ceil(Nc/2)+1); % 32
    X = zeros(sizeSubArray,nSubArray,samples); % 30 * 32 * samples
    CSI = zeros(sizeSubArray,nSubArray,samples); % 30 * 32 * samples
end

% 导向矢量的构建要和流型矩阵“对齐”，根据option参数，决定导向矩阵的构建方式
for ipath = 1:paths
    A(:,ipath) = util_steering_aoa_tof(theta(ipath),tau(ipath), ...
                                        Nrx,ant_dist,fc,Nc,Delta_f, option);
end
% 计算导向矢量，注意这里是生成的信号，而不是真实的信号，路径的数量paths是已知的
% 因此是生成少量的导向矢量就可以
% 如果是真实的信号路径数量未知，那么就设置的aoa以及tof矢量
% 对于每个aoa 以及tof 都生成导向矢量
% aoa = -90:1:90;       % -90~90 [deg]
% tof = (0:1:100)*1e-9; % 1~100 [ns]

% isCoherent = true; 是相干信号
% 信号相干，频率相同，相位差恒定


% 这里的相干信号代表什么？ 代表矩阵中有CoherentPaths行(CoherentPaths路)的数据是相关的？
% 都是ComplexConst乘以数据的第一行，不相干是paths行(paths路信号)完全独立？
% 平滑和不平滑又是代表什么？平滑代表生成更多的子阵SubArray 32个 ？？
% 快拍数代表什么？ 类似代表不同的子载波？
%{
Find all peaks of MUSIC spectrum: 
Calculated AoA: 28  30  33 [deg] 
Calculated ToF: 18  43  73 [ns]

Find Direct Path AoA and ToF: 
(AOA, ToF) =  (10 [deg], 18 [ns]) 

注意这里的估计结果，tof是按小到大进行排序，而LOS的tof也是按照时间大小进行排序，
故LOStof在 Calculated ToF中，而	Calculated AoA的计算则不是按照角度大小进行输出
并未考虑相应tof值的大小，因此LOS的AOA不在Calculated AoA中
%}

global isCoherent CoherentPaths
if isCoherent % 测试相干信源
    Gamma_temp = randn(paths - CoherentPaths, samples) + ...
		randn(paths - CoherentPaths, samples)*1j; % complex attuation(不相干信源)
    ComplexConst = randn+1j*randn;
    % 生成与第一条和二条路径信号相干的接收信号
    if strcmp(option,'non-smoothing')
        Gamma = [Gamma_temp; ComplexConst*repmat(Gamma_temp(1,:),CoherentPaths,1)];
		% 最后CoherentPaths行相关？？
		% Gamma paths * samples
		 % 对于非平滑是1个paths * samples ，对于平滑方式是nSubArray个paths * samples矩阵
    elseif strcmp(option,'smoothing')
	% 对于平滑是 nSubArray个paths * samples
        nSubArray = ceil(Nrx/2)*(Nc - ceil(Nc/2)+1); % 32 = 2*16
        Gamma = cell(nSubArray,1);
        for iSubArray = 1:nSubArray
            % 不同子阵的衰落独立，不同快拍的衰落独立
            Gamma_temp = randn(paths-CoherentPaths,samples) + ...
				randn(paths-CoherentPaths,samples)*1j; % complex attuation(不相干信源)
            ComplexConst = randn+1j*randn;
            Gamma{iSubArray} = [Gamma_temp; ComplexConst*repmat(Gamma_temp(1,:), CoherentPaths, 1)];
        end
    end
else
	% 非相干信号源
    Gamma = randn(paths,samples)+randn(paths,samples)*1j; % complex attuation
end

global lambda
if nargin == 10 || (nargin == 11 && strcmp(option, 'non-smoothing'))
    X = A*Gamma; % 90*paths * paths*samples = 90*samples
    CSI =awgn(X,SNR,'measured'); % 90*samples
    save('CSI.mat','CSI', 'A');
	% 将矩阵CSI 以及A都保存到CSI.mat中
elseif nargin == 11 && strcmp(option, 'smoothing')
	% 对于smoothing的CSI数据的构造不能直接A F相乘吗 ？？
    nSubArray = ceil(Nrx/2)*(Nc-ceil(Nc/2)+1); % 32
    beta = 2*pi*ant_dist*sin(theta)/lambda; %D beta的长度就是theta的长度，和paths同样长
    D = diag(exp(-1j*beta)); % paths * paths
    for iSubArray = 1: nSubArray
        if iSubArray <= nSubArray/2
            X(:,iSubArray,:) = A*D^(iSubArray-1)*Gamma{iSubArray};
			% 30*paths * paths*paths * paths*samples = 30*samples
			% 这一部分就是空间平滑的逆过程
        else
            Phi = exp(-1j*2*pi*1*ant_dist*sin(theta*pi/180)/lambda);
            D = D*diag(Phi);
            X(:,iSubArray,:) = A*D.^(iSubArray-1)*Gamma{iSubArray};
        end
        CSI(:,iSubArray,:) = awgn(squeeze(X(:,iSubArray,:)),SNR,'measured');
    end
    save('CSI.mat','CSI', 'A');
end
end