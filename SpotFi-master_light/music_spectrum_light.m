function Pmusic = music_spectrum_light(theta,tau,frequency, sub_freq_delta, antenna_distance,eigenvectors)

	Pmusic = zeros(length(theta), length(tau));
	% 计算导向矢量
	for ii = 1:length(theta)
		for jj = 1:length(tau)
			steering_vector = compute_steering_vector(theta(ii), tau(jj), ...
					frequency, sub_freq_delta, antenna_distance);
			PP = steering_vector' * (eigenvectors * eigenvectors') * steering_vector;
			Pmusic(ii, jj) = abs(1 /  PP);
		end
	end
	% 得到伪谱矩阵Pmusic
	% 没有必要这样再求一个log，再求绝对值，log之后可能为负值，abs之后就为正，造成图像反转
	%{
	for ii = 1:size(Pmusic, 1)
		% AoA loop
		for jj = 1:size(Pmusic, 2)
			Pmusic(ii, jj) = 10 * log10(Pmusic(ii, jj));
			%Pmusic(ii, jj) = abs(Pmusic(ii, jj));
		end
	end
	%}
end

function time_phase = omega_tof_phase(tau, sub_freq_delta)
    time_phase = exp(-1i * 2 * pi * sub_freq_delta * tau);
end

function angle_phase = phi_aoa_phase(theta, frequency, d)
    c = 3.0 * 10^8;
    theta = theta / 180 * pi;
    angle_phase = exp(-1i * 2 * pi * d * sin(theta) * (frequency / c));
end

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