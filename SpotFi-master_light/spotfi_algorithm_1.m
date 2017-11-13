%% Time of Flight (ToF) Sanitization Algorithm, find a linear fit for the unwrapped CSI phase
% csi_matrix -- the CSI matrix whose phase is to be adjusted
% delta_f    -- the difference in frequency between subcarriers
% Return:
% csi_matrix -- the same CSI matrix with modified phase
function [csi_matrix, phase_matrix] = spotfi_algorithm_1(csi_matrix, delta_f,...
	packet_one_phase_matrix)
    R = abs(csi_matrix); % csi_matrix是原始CSI相位，保留幅度
    phase_matrix = unwrap(angle(csi_matrix), pi, 2);  %按行进行消除相位跳变，phase_matrix是3*30 
    
    % Parse input args
    if nargin < 3
        packet_one_phase_matrix = phase_matrix;
    end
	% 只用了第一个数据包的展开相位 packet_one_phase_matrix
	
    % STO is the same across subcarriers....
    % Data points are:
    % subcarrier_index -> unwrapped phase on antenna_1
    % subcarrier_index -> unwrapped phase on antenna_2
    % subcarrier_index -> unwrapped phase on antenna_3
	
    fit_X(1:30, 1) = 1:1:30;
    fit_X(31:60, 1) = 1:1:30;
    fit_X(61:90, 1) = 1:1:30;
    fit_Y = zeros(90, 1);
	
    for i = 1:size(phase_matrix, 1)   % 3
        for j = 1:size(phase_matrix, 2)   % 30
            fit_Y((i - 1) * 30 + j) = packet_one_phase_matrix(i, j);   %消除相位跳变后的CSI
        end
    end
	% 可以直接用reshape进行变换   fit_Y = reshape(packet_one_phase_matrix', 90,1);
    % Linear fit is common across all antennas
    result = polyfit(fit_X, fit_Y, 1);
    tau = result(1);  % 额外时间
        
    for m = 1:size(phase_matrix, 1)  %3
        for n = 1:size(phase_matrix, 2)  % 30
            % Subtract the phase added from sampling time offset (STO)
            phase_matrix(m, n) = packet_one_phase_matrix(m, n) + (2 * pi * delta_f * (n - 1) * tau);
			%phase_matrix(m, n) = packet_one_phase_matrix(m, n) - (n - 1) * tau;
			% 所有数据包的相位都是有第一个数据包的相位packet_one_phase_matrix构建的，
			% 输出的csi_matrix，除了幅值不一样外，相位都是一样的
        end
    end
    
    % Reconstruct the CSI matrix with the adjusted phase
    csi_matrix = R .* exp(1i * phase_matrix);
end

%{
区分转置和共轭转置

csi_matrix = R .* exp(1i * phase_matrix);
[csi_matrix, phase_matrix] = spotfi_algorithm_1()
angle(csi_matrix)和phase_matrix相差很大，但是经过unwrap之后两者相差很小
%}


