% 谱函数的计算
% theta = -90:1:90; 
% tau = 0:(1.0 * 10^-9):(100 * 10^-9);
function Pmusic = music_spectrum(theta, tau, frequency, sub_freq_delta, antenna_distance,eigenvectors)
    Pmusic = zeros(length(theta), length(tau));  % size(Pmusic) = 181 * 101
    steering_matrix = compute_steering_matrix(theta, tau, frequency, ...
        sub_freq_delta, antenna_distance);
	
	% steering_matrix的每一列都是一个导向矢量,是复数的
	H = eigenvectors * eigenvectors';
    PP = zeros(1, size(steering_matrix, 2));
    for ii = 1:size(steering_matrix, 2)
        S = steering_matrix(:, ii); % 按列进行求值，也是进行了length(theta)*length(tau)次循环
        PP(ii) = S' * H * S;
    end
	
	% dim = length(theta)*length(tau);
    % steering_matrix = zeros(30, dim);
	% Pmusic = zeros(length(theta), length(tau));
	%
	
	%***
	%
    PP = reshape(PP, length(theta), length(tau));
    Pmusic = 1./abs(PP); %到这里Pmusic已经变成了实数
	
	%}
	
	%{
    PP = reshape(PP, length(tau), length(theta));
    Pmusic = 1./abs(PP.');
	% 这里得到的Pmusic和推论的结果总是一样的
	% 矩阵mx = base_element' * tmp; 要转置
	%}
	
	%{
	% original version from hkzsk
    PP = wrev(PP);
    PP = reshape(PP, length(theta), length(tau));
    Pmusic = 1./abs(PP);
    Pmusic = fliplr(Pmusic);
	%}
	%}
end


% 计算完毕，返回导向矩阵

function steering_matrix = compute_steering_matrix(theta, tau, freq, ...
    sub_freq_delta, ant_dist)
    dim = length(theta)*length(tau);
    steering_matrix = zeros(30, dim);
    k = 1;
    base_element = ones(1, length(theta));
    omega_tof = omega_tof_phase(tau, sub_freq_delta);
    phi_aoa = phi_aoa_phase(theta, freq, ant_dist);
    for ii = 1:2
        tmp = ones(1, length(tau));
        for jj = 1:15
			mx = base_element.' * tmp;  % modify **************** 改变角度的正负
            steering_matrix(k, :) = reshape(mx, 1, dim);
            tmp = tmp.*omega_tof;
            k = k + 1;
        end
        base_element = base_element .* phi_aoa;
    end
end

function time_phase = omega_tof_phase(tau, sub_freq_delta)
    time_phase = exp(-1i * 2 * pi * sub_freq_delta * tau);
end

function angle_phase = phi_aoa_phase(theta, frequency, d)
    % Speed of light (in m/s)
    c = 2.998 * 10^8;
    % Convert to radians
    theta = theta / 180 * pi;
    angle_phase = exp(-1i * 2 * pi * d * sin(theta) * (frequency / c));
end
% frequency 是否又进一步优化的可能？？














function steering_vector = compute_steering_vector(theta, tau, freq, sub_freq_delta, ant_dist)
    steering_vector = zeros(30, 1);
    k = 1;
    base_element = 1;
    for ii = 1:2
        for jj = 1:15
            steering_vector(k, 1) = base_element * omega_tof_phase(tau, sub_freq_delta)^(jj - 1);
            k = k + 1;
        end
        base_element = base_element * phi_aoa_phase(theta, freq, ant_dist);
    end
end

% 导向矢量是如何构建的？导向矢量和协方差矩阵有什么关系？