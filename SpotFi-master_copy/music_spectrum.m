% 谱函数的计算
% theta = -90:1:90; 
% tau = 0:(1.0 * 10^-9):(100 * 10^-9);
function Pmusic = music_spectrum(theta,tau,frequency, sub_freq_delta, antenna_distance,eigenvectors)
    

	
	steering_matrix = compute_steering_matrix(theta, tau, frequency, ...
        sub_freq_delta, antenna_distance);
		
    H = eigenvectors*eigenvectors';
    PP = zeros(1, size(steering_matrix, 2));
    
    for ii = 1:size(steering_matrix, 2)
        S = steering_matrix(:,ii);
        PP(ii) = S' * H * S;
    end
    
    PP = reshape(PP, length(tau), length(theta));
    Pmusic = 1./abs(PP');
end


% 计算完毕，返回导向矩阵

function steering_matrix = compute_steering_matrix(aoa, tof, freq, ...
    sub_freq_delta, ant_dist)
    dim = length(aoa)*length(tof);
    steering_matrix = zeros(2*15, dim);
    base_element = ones(1, length(aoa));
    omega_tof = omega_tof_phase(tof, sub_freq_delta);
    phi_aoa = phi_aoa_phase(aoa, freq, ant_dist);
    k = 1;
    for ii = 1:2
        tmp = ones(length(tof), 1);
        for jj = 1:15
            steering_matrix(k, :) = reshape(tmp * base_element, 1, dim);
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
    time_phase = exp(-1i * 2 * pi * sub_freq_delta * tau');
end

%% Compute the phase shifts across the antennas as a function of AoA
% theta       -- the angle of arrival (AoA) in degrees
% frequency   -- the frequency of the signal being used
% d           -- the spacing between antenna elements
% Return:
% angle_phase -- complex exponential representing the phase shift from angle of arrival
function angle_phase = phi_aoa_phase(theta, frequency, d)
    % Speed of light (in m/s)
    c = 3e8;
    % Convert to radians
    theta = theta / 180 * pi;
    angle_phase = exp(-1i * 2 * pi * d * sin(theta) * (frequency / c));
end