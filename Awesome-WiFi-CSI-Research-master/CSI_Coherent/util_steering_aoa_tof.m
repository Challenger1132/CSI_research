%% 分为平滑和非平滑两种情况
function steering_vector = util_steering_aoa_tof(aoa,tof,Nrx,ant_dist,fc,Nc,Delta_f,option)
    if nargin <= 7 || (nargin == 8 && strcmp(option,'non-smoothing'))
		% 三天线上转开的导向矢量的构建方式 90*1
        steering_vector = zeros(Nrx*Nc,1); % 90个？
        Phi = zeros(Nrx,1);
        Omega = zeros(Nc,1);
        lambda = 3e8/fc;
        for i = 1:Nrx
            Phi(i) = exp(-1j*2*pi*(i-1)*ant_dist*sin(aoa*pi/180)/lambda);
            for j = 1:Nc
                Omega(j) = exp(-1j*2*pi*(j-1)*Delta_f*tof);
                steering_vector((i-1)*Nc + j) = Phi(i)*Omega(j);
            end
        end
    end
    if nargin == 8 && strcmp(option,'smoothing')
		% 根据平滑结果进行的导向矢量构建方式 30*1
        steering_vector = zeros(ceil(Nrx/2)*ceil(Nc/2), 1);  % 30 * 1 
        k = 1;
        base_element = 1;
        for ii = 1:ceil(Nrx/2)
            for jj = 1:ceil(Nc/2)
                steering_vector(k, 1) = base_element * omega_tof_phase(tof, Delta_f)^(jj - 1);
                k = k + 1;
            end
            base_element = base_element * phi_aoa_phase(aoa, fc, ant_dist);
        end
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

