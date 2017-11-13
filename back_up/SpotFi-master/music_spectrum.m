% 谱函数的计算
% theta = -90:1:90; 
% tau = 0:(1.0 * 10^-9):(100 * 10^-9);
function Pmusic = music_spectrum(theta,tau,frequency, sub_freq_delta, antenna_distance,eigenvectors)
    Pmusic = zeros(length(theta), length(tau));  % size(Pmusic) = 181 * 101
    % Angle of Arrival Loop (AoA)
    for ii = 1:length(theta)   % 181
        % Time of Flight Loop (ToF)
        for jj = 1:length(tau)  % 101
            steering_vector = compute_steering_vector(theta(ii), tau(jj), ...
                    frequency, sub_freq_delta, antenna_distance);
					%由theta(ii), tau(jj) 构造的导向矢量 eigenvectors 是噪声空间向量
					% 是不是每一个  theta and tau 都可以构造一个导向矢量？
					% steering_vector   30*1
					% steering_vector是导向矩阵的每一列
            PP = steering_vector' * (eigenvectors * eigenvectors') * steering_vector;
            Pmusic(ii, jj) = abs(1 / PP);
        end
    end
	% 用循环来进行求导向矢量，对于每一个Θ和tau，对应一个大小为30的列向量，
	% 而这样的列向量有length(theta)*length(tau)个，是按照一列一列来进行求值的
	
	% 对CSI的协方差矩阵R进行分解，得到信号空间和噪声空间，噪声空间和导向矩阵的列向量相互正交
	% 而导向矩阵的每个列向量对应于一个路径的角度Θ
	% 可以用天线间距离和子载波间隔两个参数构造导向矢量
	% 信号空间列向量的数目就是多径的数目
	% 分母是信号向量和噪声矩阵的内积，当两针正交的时候，值为0，
	% 但是现实环境有噪声的影响，是一个很小的值，因此Pmusic有一个尖峰
    % Convert to decibels
    % ToF loop
    for jj = 1:size(Pmusic, 2)  % 101
        % AoA loop
        for ii = 1:size(Pmusic, 1)  % 181
            Pmusic(ii, jj) = 10 * log10(Pmusic(ii, jj));% / max(Pmusic(:, jj))); 
            Pmusic(ii, jj) = abs(Pmusic(ii, jj));
        end
    end
end   % 输出db形式


%% Computes the steering vector for SpotFi. 
% Each steering vector covers 2 antennas on 15 subcarriers each. 2天线 15子载波
% theta           -- the angle of arrival (AoA) in degrees
% tau             -- the time of flight (ToF)
% freq            -- the central frequency of the signal
% sub_freq_delta  -- the frequency difference between subcarrier
% ant_dist        -- the distance between each antenna
% Return:
% steering_vector -- the steering vector evaluated at theta and tau
%
% NOTE: All distance measurements are in meters
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

%% Compute the phase shifts across subcarriers as a function of ToF
% tau             -- the time of flight (ToF)
% frequency_delta -- the frequency difference between adjacent subcarriers
% Return:
% time_phase      -- complex exponential representing the phase shift from time of flight

function time_phase = omega_tof_phase(tau, sub_freq_delta)  %计算相邻子载波之间的相位偏移
    time_phase = exp(-1i * 2 * pi * sub_freq_delta * tau);
end  %返回值是 复数指数代表的 从TOF中获取的 相位偏移

%% Compute the phase shifts across the antennas as a function of AoA
% theta       -- the angle of arrival (AoA) in degrees
% frequency   -- the frequency of the signal being used
% d           -- the spacing between antenna elements
% Return:
% angle_phase -- complex exponential representing the phase shift from angle of arrival
% 计算由于天线差引入的路程差，进而引入的相位差
function angle_phase = phi_aoa_phase(theta, frequency, d)
    % Speed of light (in m/s)
    c = 3.0 * 10^8;
    % Convert to radians
    theta = theta / 180 * pi;
    angle_phase = exp(-1i * 2 * pi * d * sin(theta) * (frequency / c));
end