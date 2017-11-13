% 谱函数的计算
% theta = -90:1:90; 
% tau = 0:(1.0 * 10^-9):(100 * 10^-9);
function Pmusic = music_spectrum(theta,tau,frequency, sub_freq_delta, antenna_distance,eigenvectors)
    Pmusic = zeros(length(theta), length(tau));  % size(Pmusic) = 181 * 101
    steering_matrix = compute_steering_matrix(theta, tau, frequency, ...
        sub_freq_delta, antenna_distance);
	% steering_matrix的每一列都是一个导向矢量
	H = eigenvectors * eigenvectors';
    PP = zeros(1, size(steering_matrix, 2));
    for ii = 1:size(steering_matrix, 2)
        S = steering_matrix(:,ii); % 按列进行求值，也是进行了length(theta)*length(tau)次循环
        PP(ii) = S' * H * S;
    end
	% dim = length(theta)*length(tau);
    % steering_matrix = zeros(30, dim);
	% Pmusic = zeros(length(theta), length(tau));
	
	%***
    PP = wrev(PP);
    PP = reshape(PP, length(theta), length(tau));
    Pmusic = 1./abs(PP);
    Pmusic = fliplr(Pmusic);
    Pmusic = 10*log10(Pmusic);
	
	%{
    PP = reshape(PP, length(tau), length(theta));
    Pmusic = 1./abs(PP');
    Pmusic = 10*log10(Pmusic);
	% 这里得到的Pmusic和推论的结果总是不一致？？
	% 矩阵mx = base_element' * tmp;要转置
	%}
	
	%{
	% 这里的实现和和***处是一样的，只是得到的数值相反，如果将该处的矩阵进行上下翻转，
	% 也就是加上PP = flipud(PP);得到的结果一致
	PP = reshape(PP, length(theta), length(tau));
	%PP = flipud(PP);
    Pmusic = 1./abs(PP);
    Pmusic = 10*log10(Pmusic);
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
			mx = base_element' * tmp;
            steering_matrix(k, :) = reshape(mx, 1, dim);
            tmp = tmp.*omega_tof;
            k = k + 1;
        end
        base_element = base_element .* phi_aoa;
    end
end

%% Compute the phase shifts across subcarriers as a function of ToF
% tau             -- the time of flight (ToF)
% frequency_delta -- the frequency difference between adjacent subcarriers
% Return:
% time_phase      -- complex exponential representing the phase shift from time of flight
function time_phase = omega_tof_phase(tau, sub_freq_delta)
    time_phase = exp(-1i * 2 * pi * sub_freq_delta * tau);
end

%% Compute the phase shifts across the antennas as a function of AoA
% theta       -- the angle of arrival (AoA) in degrees
% frequency   -- the frequency of the signal being used
% d           -- the spacing between antenna elements
% Return:
% angle_phase -- complex exponential representing the phase shift from angle of arrival
function angle_phase = phi_aoa_phase(theta, frequency, d)
    % Speed of light (in m/s)
    c = 3.0 * 10^8;
    % Convert to radians
    theta = theta / 180 * pi;
    angle_phase = exp(-1i * 2 * pi * d * sin(theta) * (frequency / c));
end