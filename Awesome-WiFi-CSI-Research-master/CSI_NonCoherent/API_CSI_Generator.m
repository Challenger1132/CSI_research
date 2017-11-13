%% CSI-GENERATOR Generate CSI Measurements 
% 
% Developed by Wu Zhiguo(Beijing University of Post and Telecommunication)
% QQ group for discusion: 366102075
% EMAIL:1600682324@qq.com wuzhiguo@bupt.edu.cn
% Github: https://github.com/wuzhiguocarter/Awesome-WiFi-CSI-Research
% Blog: http://www.jianshu.com/c/6e0897ba0cec [WiFi CSI Based Indoor Localization]

function [CSI,A] = API_CSI_Generator(theta, tau, paths, ...
                            Nrx,ant_dist,samples, ...
                            fc,Nc,Delta_f,SNR)

    A = zeros(Nrx*Nc,paths); % 90 * paths
    X = zeros(Nrx*Nc,samples); % 90 * samples
    CSI = zeros(Nrx*Nc,samples); % 90 * samples
for ipath = 1:paths
    A(:,ipath) = util_steering_aoa_tof(theta(ipath),tau(ipath), ...
                                        Nrx,ant_dist,fc,Nc,Delta_f);
end


global isCoherent CoherentPaths

if isCoherent % 测试相干信源
    Gamma_temp = randn(paths-CoherentPaths,samples) + randn(paths-CoherentPaths, samples)*1j; % complex attuation(不相干信源)
    ComplexConst = randn+1j*randn;
    % 生成与第一条和二条路径信号相干的接收信号
    Gamma = [Gamma_temp;ComplexConst*repmat(Gamma_temp(1, :), CoherentPaths, 1)];
else
    Gamma = randn(paths,samples) + randn(paths,samples)*1j; % complex attuation
end

X = A*Gamma; % 
CSI =awgn(X,SNR,'measured');
save('CSI.mat','CSI', 'A');
end