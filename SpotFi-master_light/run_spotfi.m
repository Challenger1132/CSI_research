%Write by Joey
%aoa_packet_data:每个数据包的aoa，即从每个数据包的music频谱得到的波峰对应的aoa
%tof_packet_data:每个数据包的tof，即从每个数据包的music频谱得到的波峰对应的tof
%output_top_aoaos:前5个最有可能是直达路径的AOA
function [Pmusics, eigenvalue] = run_spotfi(filepath)
	%% configuration
    antenna_distance = 0.0261;  % 天线距离
    frequency = 5.745 * 10^9;  % 频率
    sub_freq_delta = 4*0.3125*10^6;  % 子载波间隔
	
	theta = -90:1:90;
	tau = (-100 * 10^-9):(1.0 * 10^-9):(100 * 10^-9);
	% tau = 0:(1.0 * 10^-9):(100 * 10^-9);
    
	csi_trace = readfile(filepath);
    num_packets = floor(length(csi_trace)/1);
	
    sampled_csi_trace = csi_sampling(csi_trace, num_packets, 1, length(csi_trace));

    [Pmusics, eigenvalue] = spotfi(sampled_csi_trace,frequency, sub_freq_delta, antenna_distance, theta, tau);
	
	num_packets = 5;
	plot_result(Pmusics, theta, tau, num_packets);
end

%为什么进行采样？
%tau = result(1);线性拟合是如何做的？
% 特征向量计算的下半部分
% 假设拥有p个AOA峰值，那么 estimated_aoas 是 p * 1
% estimated_tofs 是 p * length(tau) 的矩阵