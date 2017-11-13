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
clc;clear;close all;

%% 全局参数配置
CSI_Configure();

%% 引用全局参数
global Nrx ant_dist
global paths theta tau  
global fc Nc Delta_f
global SNR samples
global param

disp('Display All Global Paramters: ');
param
%% 设置的多径AoA和ToF信息
fprintf('True ToF and AoA of all paths: \n');
for ipath = 1:paths
    disp(['path ' num2str(ipath) ': (AoA, ToF) = (' num2str(theta(ipath)) ...
        ' [deg], ' num2str(tau(ipath)*1e9) ' [ns])' ]);
end

%% 生成观测矩阵CSI和导向向量A
[CSI,A] = API_CSI_Generator(theta, tau, paths, ...
                            Nrx,ant_dist,samples, ...
                            fc,Nc,Delta_f,SNR);
                        
%% 计算MUSIC伪谱，寻找谱峰，估计AoA和ToF，并可视化,存为jpeg
API_CSI_MUSIC_Visualize(CSI,samples,paths, Nrx,ant_dist, ...
                            fc,Nc,Delta_f);
