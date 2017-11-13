
% 										x = smoothed_sanitized_csi 30*32
function [Pmusic] = aoa_tof_music(x, ...
        antenna_distance, frequency, sub_freq_delta, data_name)
    if nargin == 4
        data_name = '-';
    end
    
    eigenvectors = noise_space_eigenvectors(x);  %得到噪声空间

    theta = -90:1:90; 
    tau = 0:(1.0 * 10^-9):(100 * 10^-9);
	Pmusic = music_spectrum(theta,tau,frequency, sub_freq_delta, antenna_distance,eigenvectors);
    % Pmusic = music_spectrum_light(theta,tau,frequency, sub_freq_delta, antenna_distance,eigenvectors);
end   

