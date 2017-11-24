
function [CSI,A] = nonRealSignal(theta, tau, paths, ...
                            ant_dist,samples, ...
                            fc,Delta_f,SNR)
    sizeSubArray = 30;
    A = zeros(sizeSubArray, paths); % 30 * paths 
    nSubArray = 32;
    X = zeros(sizeSubArray,nSubArray,samples); % 30 * 32 * samples
    CSI = zeros(sizeSubArray,nSubArray,samples); % 30 * 32 * samples

	for ipath = 1:paths
		steering_vector = zeros(30, 1);  % 30 * 1 
		k = 1;
		base_element = 1;
		
		for ii = 1:2
			for jj = 1:15
				steering_vector(k, 1) = base_element * omega_tof_phase(tau(ipath), Delta_f)^(jj - 1);
				k = k + 1;
			end
			base_element = base_element * phi_aoa_phase(theta(ipath), fc, ant_dist);
		end
		
		A(:,ipath) = steering_vector;
	end

	CoherentPaths = 2;

	Gamma_temp = randn(paths - CoherentPaths, samples) + ...
		randn(paths - CoherentPaths, samples)*1j; % complex attuation(不相干信源)
	ComplexConst = randn+1j*randn;
	nSubArray = 32;
	Gamma = cell(nSubArray,1);
	for iSubArray = 1:nSubArray
		% 不同子阵的衰落独立，不同快拍的衰落独立
		Gamma_temp = randn(paths-CoherentPaths,samples) + ...
			randn(paths-CoherentPaths,samples)*1j; % complex attuation(不相干信源)
		ComplexConst = randn+1j*randn;
		Gamma{iSubArray} = [Gamma_temp; ComplexConst*repmat(Gamma_temp(1,:), CoherentPaths, 1)];
	end

		
	LIGHTSPEED = 3e8;                   % 光速 3*10^8 [m/s]
	fc = 5.8e9;                         % 5.8GHz
	lambda = LIGHTSPEED/fc;
	beta = 2*pi*ant_dist*sin(theta)/lambda; %D beta的长度就是theta的长度，和paths同样长
	D = diag(exp(-1j*beta)); % paths * paths
	for iSubArray = 1: nSubArray
		if iSubArray <= nSubArray/2
			X(:,iSubArray,:) = A*D^(iSubArray-1)*Gamma{iSubArray};
			% 30*paths * paths*paths * paths*samples = 30*samples
			% 这一部分就是空间平滑的逆过程
		else
			Phi = exp(-1j*2*pi*1*ant_dist*sin(theta*pi/180)/lambda);
			D = D*diag(Phi);
			X(:,iSubArray,:) = A*D.^(iSubArray-1)*Gamma{iSubArray};
		end
		CSI(:,iSubArray,:) = awgn(squeeze(X(:,iSubArray,:)),SNR,'measured');
	end
end

function time_phase = omega_tof_phase(tau, sub_freq_delta)
    time_phase = exp(-1i * 2 * pi * sub_freq_delta * tau);
end
function angle_phase = phi_aoa_phase(theta, frequency, d)
    % Speed of light (in m/s)
    c = 3.0 * 10^8;
    % Convert to radians
    theta = theta / 180 * pi;
    angle_phase = exp(-1i * 2 * pi * d * sin(theta) * (frequency / c));
end