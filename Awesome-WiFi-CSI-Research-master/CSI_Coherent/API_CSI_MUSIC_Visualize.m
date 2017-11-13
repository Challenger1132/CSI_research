
%% Xt是Smooth_CSI
function [Pmusic] = API_CSI_MUSIC_Visualize(Xt,...
			samples, paths, Nrx, ant_dist, fc, Nc, Delta_f, option)
if strcmp(option,'non-smoothing')
    Rxx = Xt*Xt'/samples; % 90*90
elseif strcmp(option,'smoothing')
    Rxx = zeros(size(Xt,1)); % Xt维度是 30x32x1025 Rxx的维度是
    for isamples = 1:samples
        Xt_squeeze = squeeze(Xt(:,:,isamples)); % 30*32 取出第isamples个数据包(切片)
        Rxx = Rxx + Xt_squeeze*Xt_squeeze'; % 30*30
    end
    Rxx = Rxx/samples;  %多个数据包的求和
end

[eigvec_mat, diag_mat_of_eigval] = eig(Rxx); % 返回特征向量矩阵与特征值对角矩阵
eigval = diag(diag_mat_of_eigval);     % 取所有特征值
% [sorted_eigval,IndexVector]=sort(eigval);        % 对特征值升序排序，并返回index vector
% % 将特征向量矩阵按列调整顺序，调整原则为：大的特征值对应的特征向量靠左排
% % 即特征向量按特征值进行降序排列，把特征值看做key，把特征向量看做value
% eigvec_mat=fliplr(eigvec_mat(:,IndexVector)); 

[sorted_eigval,IndexVector] = sort(eigval,'descend');
%默认是升序排序ascend，参数指定降序排序descend，对矩阵按列进行排序，保存原来的索引
eigvec_mat = eigvec_mat(:,IndexVector); 
% 对eigvec_mat矩阵的每一列按照IndexVector，进行重新调整


%% 信源数估计
global USE_NumOfSignalsEstimation

if ~USE_NumOfSignalsEstimation
    L = paths;  % 不使用信源数估计，直接人为给出
else
    % 'AIC','MDL','HQ','EGM1','EGM2'
    algo_option = 'EGM1';  % 估计算法
    L = util_getNumOfSignals(sorted_eigval,samples,algo_option);
	L = L;
	
	% samples相当于有多少个数据包的CSI数据
    fprintf('\nUsing %s NumOfSignalsEstimation, Estimate Paths is %d\n',algo_option, L);
end
%% 计算MUSIC伪谱
aoa = -90:1:90;       % -90~90 [deg]
tof = (0:1:100)*1e-9; % 1~100 [ns]

En = eigvec_mat(:, L+1:size(Rxx, 1));
Pmusic = zeros(length(aoa),length(tof));
for iAoA = 1:length(aoa)
    for iToF = 1:length(tof)
        a = util_steering_aoa_tof(aoa(iAoA), tof(iToF), Nrx, ant_dist, fc, Nc, Delta_f, option);
		% 直接找后length(eigvec_mat) - L列,是噪声空间向量
		% 噪声空间是30* (length(eigvec_mat) - L) ***
		% 而导向矢量是30 * 1
        %Pmusic(iAoA,iToF) = abs(1/(a'*(En*En')*a));
        % 归一化MUSIC伪谱
        Pmusic(iAoA,iToF) = abs((a'*a)/(a'*(En*En')*a));
    end
end

LOG_DATE = strrep(datestr(now,30),'T','');  % 时间字符串，替换掉字符T

%% MUSIC_AOA_TOF可视化
SPmax = max(max(Pmusic));
Pmusic = 10*log10(Pmusic/SPmax);
hMUSIC = figure('Name', 'MUSIC_AOA_TOF1', 'NumberTitle', 'off');
[meshAoA,meshToF] = meshgrid(aoa,tof);
mesh(meshAoA, meshToF*1e9, Pmusic');

xlabel('X Angle of Arrival in degrees[deg]');
ylabel('Y Time of Flight[ns]');
zlabel('Z Spectrum Peaks[dB]');
title('AoA and ToF Estimation from Modified MUSIC Algorithm');
axis([-90 90 0 100]);
view(3);
grid on; hold on;
fprintf('\nFind all peaks of MUSIC spectrum: \n');

%{
hMUSIC = figure('Name', 'MUSIC_AOA_TOF2', 'NumberTitle', 'off');
[meshAoA, meshToF] = meshgrid(aoa, tof);
mesh(meshToF*1e9, meshAoA, Pmusic');
% axis([-90 90 0 100]);
ylabel('Y Angle of Arrival in degrees[deg]')
xlabel('X Time of Flight[ns]')
zlabel('Z Spectrum Peaks[dB]')
title('AoA and ToF Estimation from Modified MUSIC Algorithm');
grid on; hold on;
fprintf('\nFind all peaks of MUSIC spectrum: \n');

hMUSIC = figure('Name', 'MUSIC_AOA_TOF3', 'NumberTitle', 'off');
[meshToF, meshAoA] = meshgrid(tof, aoa);
mesh(meshToF*1e9, meshAoA, Pmusic);
% axis([-90 90 0 100]);
ylabel('Y Angle of Arrival in degrees[deg]')
xlabel('X Time of Flight[ns]')
zlabel('Z Spectrum Peaks[dB]')
title('AoA and ToF Estimation from Modified MUSIC Algorithm');
grid on; hold on;
fprintf('\nFind all peaks of MUSIC spectrum: \n');
%}



global PLOT_MUSIC_AOA PLOT_MUSIC_TOF 
global SAVE_FIGURE
%% MUSIC_AOA可视化
if 	PLOT_MUSIC_AOA
    num_computed_paths = L;
    figure_name_string = sprintf('MUSIC_AOA, Number of Paths: %d', num_computed_paths);
    figure('Name', figure_name_string, 'NumberTitle', 'off')

    PmusicEnvelope_AOA = zeros(length(aoa),1);
    for i = 1:length(aoa)
        PmusicEnvelope_AOA(i) = max(Pmusic(i,:)); 
		% 角度最大值，是按行进行搜索，找的是角度最大值的的包络
    end

    plot(aoa, PmusicEnvelope_AOA, '-r')
    xlabel('x_Angle, \theta[deg]')
    ylabel('y_Spectrum function P(\theta, \tau)  / dB')
    title('AoA Estimation')
    grid on;grid minor;hold on;

   %% 计算所有路径的AoA
    % 降序返回前paths大的峰值及其索引
    [pktaoa,lctaoa]  = findpeaks(PmusicEnvelope_AOA,...
		'SortStr','descend','NPeaks',num_computed_paths);
	% findpeaks出现一个峰值就对应记录一个index，峰值和index是对应的
	% 这里，返回的的lct是峰值的下标，不是真正的角度theta值，若使用角度使用aoa(lct)
	% 注意这个地方 PmusicEnvelope_AOA是列向量，因此返回的pkt以及lct也是列向量
    % pkt是峰值，lct是峰值在PmusicEnvelope_AOA出现的index
	% plot(lct,pkt,'o','MarkerSize',12)
    plot(aoa(lctaoa),pktaoa,'o','MarkerSize',12)
    % 升序输出峰值的索引
	disp(['Calculated AoA: ' num2str(sort(round(aoa(lctaoa)),'ascend')) ' [deg] ']);
    
    if SAVE_FIGURE
        figureName = ['./figure/' LOG_DATE '_' 'MUSIC_AOA' '.jpg'];
        saveas(gcf,figureName);
    end
end

%% MUSIC_TOF可视化
if 	PLOT_MUSIC_TOF
    figure_name_string = sprintf('MUSIC_TOF, %d paths', num_computed_paths);
    figure('Name', figure_name_string, 'NumberTitle', 'off');
    PmusicEnvelope_ToF = zeros(length(tof),1);
    for i = 1:length(tof)
        PmusicEnvelope_ToF(i) = max(Pmusic(:,i)); % 时间峰值，是按列进行搜索
    end

    plot(tof*1e9, PmusicEnvelope_ToF, '-k')
    xlabel('ToF, \tau[ns]')
    ylabel('Spectrum function P(\theta, \tau)  / dB')
    title('ToF Estimation')
    grid on; grid minor; hold on;
   %% 计算所有路径的ToF
    [pkttof, lcttof]  = findpeaks(PmusicEnvelope_ToF,...
		'SortStr', 'descend', 'NPeaks', num_computed_paths); % 'MinPeakHeight',-4
	% descend是对峰值进行降序排序的，对应的index相应改变
	% 第二个参数有错误
	% PmusicEnvelope_ToF是tof 峰值包络返回lct刚好是时间，因为
	
    plot(tof(lcttof)*1e9, pkttof,'o','MarkerSize',12)
    disp(['Calculated ToF: ' num2str(sort(round(tof(lcttof)*1e9),'ascend')) ' [ns]'] );
	% disp(['Calculated ToF: ' num2str(sort(round(tau(lctof)),'ascend')) ' [ns] ']);
    
    if SAVE_FIGURE
        figureName = ['./figure/' LOG_DATE '_' 'MUSIC_TOF' '.jpg'];
        saveas(gcf,figureName);
    end
    
   %% 计算直射径AoA和ToF
    fprintf('\nFind Direct Path AoA and ToF: \n')
    direct_path_tof_index = find(tof == tof(min(lcttof)));
	% 不就是PmusicEnvelope_ToF findpeaks的第一个峰值的index吗 ？？？
    direct_path_tof = tof(min(lcttof))*1e9; % 单位是 ns
	
    [~,direct_path_aoa_index] = max(Pmusic(:,direct_path_tof_index));
    direct_path_aoa = aoa(direct_path_aoa_index);
	% 先找tof的最小值，确定为LOS
	% 在一个矩阵中找某个值是找index Pmusic(i, j)
	% 在plot绘图的时候，绘制的是index对应的真实的值
	
    disp(['(AOA, ToF) =  ('  num2str(direct_path_aoa) ' [deg], '  ...
       num2str(direct_path_tof) ' [ns]) ']);

   %% 在MUSIC伪谱中标记直射径
    % set(groot,'CurrentFigure',hMUSIC);hold on;
    x_aoa = direct_path_aoa;
    y_tof = direct_path_tof;
    z_dB = Pmusic(direct_path_aoa_index,direct_path_tof_index);
	currentAxis = get(hMUSIC, 'CurrentAxes');
   % plot3(currentAxis, x_aoa,y_tof,z_dB,'o','MarkerSize',12);
	scatter3(currentAxis, x_aoa, y_tof, z_dB, 'filled', 'MarkerEdgeColor','r');
	
    txt = sprintf('Direct Path: \n( %d[deg], %d[ns])', ...
        round(direct_path_aoa), ...
        round(direct_path_tof));
     text(currentAxis, x_aoa,y_tof,txt);
	
    % 设置figure hMUSIC为当前视图

    figure(hMUSIC);
    view(-60,30);
    
    if SAVE_FIGURE
        figureName = ['./figure/' LOG_DATE '_' 'MUSIC_AOA_TOF' '.jpg'];
        saveas(gcf,figureName);
    end
end
end


