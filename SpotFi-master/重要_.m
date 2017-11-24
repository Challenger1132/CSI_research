% 谱函数的计算
% theta = -90:1:90; 
% tau = 0:(1.0 * 10^-9):(100 * 10^-9);


function Pmusic = music_spectrum(theta,tau,frequency, sub_freq_delta, antenna_distance,eigenvectors)
    Pmusic = zeros(length(theta), length(tau));  % size(Pmusic) = 181 * 101
    steering_matrix = compute_steering_matrix(theta, tau, frequency, ...
        sub_freq_delta, antenna_distance);
	
	H = eigenvectors * eigenvectors';
    PP = zeros(1, size(steering_matrix, 2));
    for ii = 1:size(steering_matrix, 2)
        S = steering_matrix(:,ii); %按列进行求值，也是进行了length(theta)*length(tau)次循环
        PP(ii) = S' * H * S;
    end
	% V1
    PP = reshape(PP, length(tau), length(theta));
    Pmusic = 1./abs(PP');
	% 矩阵mx = base_element' * tmp; base_element要转置
	
	%{
	v2
	PP = reshape(PP, length(theta), length(tau));
    Pmusic = 1./abs(PP);
	% 矩阵mx = base_element * tmp; base_element 不需要转置
	%}
end

% 计算完毕，返回导向矩阵
% v1
function steering_matrix = compute_steering_matrix(theta, tau, freq, ...
    sub_freq_delta, ant_dist)
	% steering_matrix的每一列都是一个导向矢量
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
            steering_matrix(k, :) = reshape(mx', 1, dim);
            tmp = tmp.*omega_tof;
            k = k + 1;
        end
        base_element = base_element .* phi_aoa;
    end
end
%{
mx = base_element' * tmp;结果是：
	θ1,τ1  θ1,τ2  θ1,τ3 ...  θ1,τL
	θ2,τ1  θ2,τ2  θ2,τ3 ...  θ2,τL
	θ3,τ1  θ3,τ2  θ3,τ3 ...  θ3,τL
	θ4,τ1  θ4,τ2  θ4,τ3 ...  θ4,τL
	...
	θM,τ1  θM,τ2  θM,τ3 ...  θM,τL
进行转置，reshape：
	θ1,τ1  θ1,τ2  θ1,τ3 ...  θ1,τL  θ2,τ1  θ2,τ2  θ2,τ3 ...  θ2,τL ...
	θ1,τ1  θ1,τ2  θ1,τ3 ...  θ1,τL  θ2,τ1  θ2,τ2  θ2,τ3 ...  θ2,τL ... 平方
	θ1,τ1  θ1,τ2  θ1,τ3 ...  θ1,τL  θ2,τ1  θ2,τ2  θ2,τ3 ...  θ2,τL ... 三次方
	... 共30个
	PP(1)  PP(2)  PP(3) ...	每个列向量对应一个导向矢量
然后PP = reshape(PP, length(tau), length(theta));
    Pmusic = 1./abs(PP');
	以tau的长度进行reshape,然后进行转置
	θ1,τ1  θ1,τ2  θ1,τ3 ...  θ1,τL
	θ2,τ1  θ2,τ2  θ2,τ3 ...  θ2,τL
	θ3,τ1  θ3,τ2  θ3,τ3 ...  θ3,τL
	θ4,τ1  θ4,τ2  θ4,τ3 ...  θ4,τL  的形式
%}
%==========================================================
% v2
function steering_matrix = compute_steering_matrix(theta, tau, freq, ...
    sub_freq_delta, ant_dist)
	% steering_matrix的每一列都是一个导向矢量
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
%{
mx = base_element' * tmp;结果是：
	θ1,τ1  θ1,τ2  θ1,τ3 ...  θ1,τL
	θ2,τ1  θ2,τ2  θ2,τ3 ...  θ2,τL
	θ3,τ1  θ3,τ2  θ3,τ3 ...  θ3,τL
	θ4,τ1  θ4,τ2  θ4,τ3 ...  θ4,τL
	...
	θM,τ1  θM,τ2  θM,τ3 ...  θM,τL
不转置，reshape：
	θ1,τ1  θ2,τ1  θ3,τ1 ...  θM,τ1  θ1,τ2  θ2,τ2  θ3,τ2 ...  θM,τ2 ...
	θ1,τ1  θ2,τ1  θ3,τ1 ...  θM,τ1  θ1,τ2  θ2,τ2  θ3,τ2 ...  θM,τ2 ... 平方
	θ1,τ1  θ2,τ1  θ3,τ1 ...  θM,τ1  θ1,τ2  θ2,τ2  θ3,τ2 ...  θM,τ2 ... 三次方
	... 共30个
	PP(1)  PP(2)  PP(3) ...	每个列向量对应一个导向矢量
然后PP = reshape(PP, length(theta), length(tau));
    Pmusic = 1./abs(PP);
	以theta的长度进行reshape
	θ1,τ1  θ1,τ2  θ1,τ3 ...  θ1,τL
	θ2,τ1  θ2,τ2  θ2,τ3 ...  θ2,τL
	θ3,τ1  θ3,τ2  θ3,τ3 ...  θ3,τL
	θ4,τ1  θ4,τ2  θ4,τ3 ...  θ4,τL  的形式
%}

function time_phase = omega_tof_phase(tau, sub_freq_delta)
    time_phase = exp(-1i * 2 * pi * sub_freq_delta * tau);
end

function angle_phase = phi_aoa_phase(theta, frequency, d)
    c = 3.0 * 10^8;
    % Convert to radians
    theta = theta / 180 * pi;
    angle_phase = exp(-1i * 2 * pi * d * sin(theta) * (frequency / c));
end