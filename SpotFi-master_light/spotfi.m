
function [Pmusics, eigenvalue] = spotfi(csi_trace,...
	frequency, sub_freq_delta, antenna_distance, theta, tau)
	if nargin < 5
		theta = -90:1:90;
		tau = 0:(1.0 * 10^-9):(100 * 10^-9);
	end
    
    num_packets = length(csi_trace);
	num_packets = 10; % 为了加快执行的速度，而选取20个packages 

	Pmusics = cell(num_packets, 1);
	eigenvalue = cell(num_packets, 1);
	smoothed_sanitized_csi = zeros(30, 32);
    for packet_index = 1:num_packets
        csi_entry = csi_trace{packet_index};
        csi = get_scaled_csi(csi_entry);
        csi = csi(1, :, :); % Remove the single element dimension
        csi = squeeze(csi); % 3*30
		csi = csi([1 2 3], :);  % 将天线2和天线3数据进行置换

        
		% Sanitize ToFs with Algorithm 1
		sanitized_csi = spotfi_algorithm_1(csi, sub_freq_delta); % 3*30
		% [sanitized_csi, ~] = linear_transform_qh(csi);
		% [sanitized_csi, ~] = linear_transform_qh_modify(csi);
		% [sanitized_csi, ~] = linear_fit_spotifi(csi, sub_freq_delta);
		
        % [sanitized_csi, ~] = linear_transform_monalisa(csi);
		% [sanitized_csi, linear_fit_csi_phase] = linear_fit(csi); % 运行结果是拱形
		
		smoothed_sanitized_csi = smooth_csi(sanitized_csi);  % 原始平滑方式
		% smoothed_sanitized_csi = smooth_csi_light(sanitized_csi);  % 双向平滑方式

        [Pmusics{packet_index}, eigenvalue{packet_index}] = aoa_tof_music(...
               smoothed_sanitized_csi, antenna_distance, frequency, sub_freq_delta, theta, tau);
        fprintf('%d\n',packet_index);
    end

end