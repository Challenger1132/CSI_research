%{
  实验结论：
    - 快拍数、信噪比综合影响AoA和ToF的分辨率、准确度
    - 其他条件不变的情况下，带宽决定ToF分辨率
    - 其他条件不变的情况下，阵元数决定AoA的分辨率
    - 阵列孔径 l = (Nrx-1)*ant_dist
    - ant_dis最大取lambda/2，此时可获取最大的阵列孔径
    - 信源数L估计不准，会对AoA和ToF造成很大误差（少一个或者多一个都不行）
    - MUSIC算法只适用于非相干信源
%}


%{
isCoherent = false;
是非相干信号，Gamma = randn(paths,samples)+randn(paths,samples)*1j;
非相干信号 option是 non-smoothing


isCoherent = true;
相干信号 产生的是非相干信号
option是 smoothing 或者 non-smoothing
相干信号和非相干信号在构造 CSI数据的时候是不同的
%}


clc;clear;close all;

%% 全局参数配置
CSI_Configure();

global isRealSignal


%% 引用全局参数
global Nrx ant_dist
global paths theta tau  
global fc Nc Delta_f
global SNR samples
global param

if ~isRealSignal %非真实信号
    disp('Display All Global Paramters: ');
    param
    %% 设置的多径AoA和ToF信息
    fprintf('True ToF and AoA of all paths: \n');
    for ipath = 1:paths
        disp(['path ' num2str(ipath) ': (AoA, ToF) = (' num2str(theta(ipath)) ...
            ' [deg], ' num2str(tau(ipath)*1e9) ' [ns])' ]);
    end

    global CoherentPaths
    fprintf('\n%d from %d paths are coherent\n', CoherentPaths+1, paths);
end


global isCoherent 
isSmoothing = true;


if isSmoothing
    option = 'smoothing';
else
    option = 'non-smoothing';
end
% 相干进行平滑，非相干不进行平滑
% option = 'non-smoothing';

if ~isRealSignal % 非真实信号
%% 生成观测矩阵CSI和导向向量A,模拟数据
    [Smooth_CSI,A] = API_CSI_Generator(theta, tau, paths, ...
                            Nrx,ant_dist,samples, ...
                            fc,Nc,Delta_f,SNR,option);
else % 使用真实数据
    %CSI = load('smoothed_csi.mat'); % load返回的是一个结构体
   % Smooth_CSI = CSI.smoothed_csi_to_save;
    CSI = load('smoothed_sanitized_csi.mat');
    Smooth_CSI = CSI.smoothed_sanitized_csi_to_save;
    samples = size(Smooth_CSI,3);
    paths = -1;
    Nrx = 3;
    ant_dist = 0.10;
    fc = 5.32 * 10^9; %  5.785 * 10^9
    Nc = 30;
    Delta_f = (40 * 10^6) / 30;
end
%% 计算MUSIC伪谱，寻找谱峰，估计AoA和ToF，并可视化,存为jpeg
[Pmusic] = API_CSI_MUSIC_Visualize(Smooth_CSI,samples,paths, Nrx,ant_dist, ...
                            fc,Nc,Delta_f,option);