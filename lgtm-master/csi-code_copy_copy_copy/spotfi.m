
function spotfi(csi_trace, frequency, sub_freq_delta, antenna_distance, data_name)

	if nargin < 5
        data_name = ' - ';
    end
    num_packets = length(csi_trace);
    aoa_packet_data = cell(num_packets, 1);
    tof_packet_data = cell(num_packets, 1);
    packet_one_phase_matrix = 0;
	Rxx = 0;
	for index = 1:num_packets
		csi_entry = csi_trace{index};
		csi = get_scaled_csi(csi_entry);
		csi = csi(1, :, :);
		% Remove the single element dimension
		csi = squeeze(csi); % 3 * 30
		packet_one_phase_matrix = unwrap(angle(csi), pi, 2);
		sanitized_csi = spotfi_algorithm_1(csi, sub_freq_delta);
		% Acquire smoothed CSI matrix
		smoothed_sanitized_csi = smooth_csi(sanitized_csi);
		Rxx = Rxx + smoothed_sanitized_csi;
	end
	Rxx = Rxx / num_packets;
    [aoa_packet_data{1}, tof_packet_data{1}] = aoa_tof_music(...
            Rxx, antenna_distance, frequency, sub_freq_delta, data_name);
end


function [estimated_aoas, estimated_tofs] = aoa_tof_music(x, ...
        antenna_distance, frequency, sub_freq_delta, data_name)
    R = x * x'; 
    [eigenvectors, eigenvalue_matrix] = eig(R);
    max_eigenvalue = -1111;
    for ii = 1:size(eigenvalue_matrix, 1)
        if eigenvalue_matrix(ii, ii) > max_eigenvalue
            max_eigenvalue = eigenvalue_matrix(ii, ii);
        end
    end
    for ii = 1:size(eigenvalue_matrix, 1)
        eigenvalue_matrix(ii, ii) = eigenvalue_matrix(ii, ii) / max_eigenvalue; % Normalized Eigenvalues
    end
    
    start_index = size(eigenvalue_matrix, 1) - 2; % 28
    end_index = start_index - 10; % 18
    decrease_ratios = zeros(start_index - end_index + 1, 1);
	
    k = 1;
    for ii = start_index:-1:end_index
        temp_decrease_ratio = eigenvalue_matrix(ii + 1, ii + 1) / eigenvalue_matrix(ii, ii);
        decrease_ratios(k, 1) = temp_decrease_ratio;
        k = k + 1;
    end
	
	
	
    [max_decrease_ratio, max_decrease_ratio_index] = max(decrease_ratios);

    fprintf('Max Decrease Ratio: %f\n', max_decrease_ratio)
    fprintf('Max Decrease Ratio Index: %d\n', max_decrease_ratio_index)

    index_in_eigenvalues = size(eigenvalue_matrix, 1) - max_decrease_ratio_index;
    num_computed_paths = size(eigenvalue_matrix, 1) - index_in_eigenvalues + 1;
    
    column_indices = 1:(size(eigenvalue_matrix, 1) - num_computed_paths);
    eigenvectors = eigenvectors(:, column_indices);
	
	
	%{
	[eigenvectors, eigenvalue_matrix] = eig(R);
	eigenvalues = diag(eigenvalue_matrix);
	befor_sort = eigenvalues;
	max_eigenvalue = max(eigenvalues);
	eigenvalues = eigenvalues / max_eigenvalue;  % normalized
	[sorted_eigenvalues, eigenvalues_index] = sort(eigenvalues, 'descend');
	eigenvectors = eigenvectors(:, eigenvalues_index);
	
	decrease_ratios = zeros(length(eigenvalues) - 1, 1);
	for ii = 1: length(eigenvalues) - 1
		decrease_ratios(ii) = sorted_eigenvalues(ii) / sorted_eigenvalues(ii + 1);
	end
	[max_decrease_ratio, max_decrease_ratio_index] = max(decrease_ratios);
	max_decrease_ratio_index = max_decrease_ratio_index + 1;
	num_computed_paths = length(eigenvalues) - max_decrease_ratio_index;
	noise_space_index = max_decrease_ratio_index : length(eigenvalues);
	eigenvectors = eigenvectors(:, noise_space_index);
	
	figure;
	subplot(221); plot(befor_sort);title('bofore sort');
	subplot(222); plot(sorted_eigenvalues);title('after sort');
	subplot(223); plot(decrease_ratios);title('decrease_ratios');
	subplot(224); plot(sorted_eigenvalues);title('after sort');hold on;
	plot(max_decrease_ratio_index, max(eigenvalues), 'o', 'MarkerSize', 12);
	%}
	
	
	
	
	
	
	
	
	
	%{
	[eigenvectors, eigenvalue_matrix] = eig(R);
	eigenvalue_matrix = diag(eigenvalue_matrix);
	max_eigenvalue = max(eigenvalue_matrix);
	eigenvalue_matrix = eigenvalue_matrix / max_eigenvalue;
    
    start_index = size(eigenvalue_matrix, 1) - 2;
    end_index = start_index - 10;
    decrease_ratios = zeros(start_index - end_index + 1, 1);
    k = 1;
    for ii = start_index:-1:end_index
        temp_decrease_ratio = eigenvalue_matrix(ii + 1, ii + 1) / eigenvalue_matrix(ii, ii);
        decrease_ratios(k, 1) = temp_decrease_ratio;
        k = k + 1;
    end
    [max_decrease_ratio, max_decrease_ratio_index] = max(decrease_ratios);

    index_in_eigenvalues = size(eigenvalue_matrix, 1) - max_decrease_ratio_index;
    num_computed_paths = size(eigenvalue_matrix, 1) - index_in_eigenvalues + 1;
    
    % Estimate noise subspace
    column_indices = 1:(size(eigenvalue_matrix, 1) - num_computed_paths);
    eigenvectors = eigenvectors(:, column_indices);
	
	%}
	
	
    theta = -90:1:90; 
    tau = 0:(1.0 * 10^-9):(50 * 10^-9);
	
	Pmusic = zeros(length(theta), length(tau));  % size(Pmusic) = 181 * 101
    steering_matrix = compute_steering_matrix(theta, tau, frequency, ...
        sub_freq_delta, antenna_distance);

	H = eigenvectors * eigenvectors';
    PP = zeros(1, size(steering_matrix, 2));
    for ii = 1:size(steering_matrix, 2)
        S = steering_matrix(:,ii);
        PP(ii) = S' * H * S;
    end
	
	
    PP = wrev(PP);
    PP = reshape(PP, length(theta), length(tau));
    Pmusic = 1./abs(PP);
    Pmusic = fliplr(Pmusic);
    Pmusic = 10*log10(Pmusic);
	
	

	figure('Name', 'AoA & ToF MUSIC Peaks', 'NumberTitle', 'off')
	mesh(tau, theta, Pmusic)
	xlabel('Time of Flight')
	ylabel('Angle of Arrival in degrees')
	zlabel('Spectrum Peaks')
	title('AoA and ToF Estimation from Modified MUSIC Algorithm')
	grid on


	figure_name_string = sprintf('%s: Number of Paths: %d', data_name, num_computed_paths);
	figure('Name', figure_name_string, 'NumberTitle', 'off')
	plot(theta, Pmusic(:, 1), '-k');
	xlabel('Angle, \theta')
	ylabel('Spectrum function P(\theta, \tau)  / dB')
	title('AoA Estimation as a function of theta')
	grid on


    binary_peaks_pmusic = imregionalmax(Pmusic); %
    % Get AoAs that have peaks
    % fprintf('Future estimated aoas\n')
    aoa_indices = linspace(1, size(binary_peaks_pmusic, 1), size(binary_peaks_pmusic, 1));
    aoa_peaks_binary_vector = any(binary_peaks_pmusic, 2); 
    estimated_aoas = theta(aoa_peaks_binary_vector);
    

	fprintf('Estimated AoAs\n')
	estimated_aoas

    aoa_peak_indices = aoa_indices(aoa_peaks_binary_vector);
    
    % Get ToFs that have peaks
    time_peak_indices = zeros(length(aoa_peak_indices), length(tau));
    % AoA loop (only looping over peaks in AoA found above)
    for ii = 1:length(aoa_peak_indices)
        aoa_index = aoa_peak_indices(ii);
        binary_tof_peaks_vector = binary_peaks_pmusic(aoa_index, :);
        matching_tofs = tau(binary_tof_peaks_vector);
        
        % Pad ToF rows with -1s to have non-jagged matrix
        negative_ones_for_padding = -1 * ones(1, length(tau) - length(matching_tofs));
        time_peak_indices(ii, :) = horzcat(matching_tofs, negative_ones_for_padding);
    end

    
	figure('Name', 'BINARY Peaks over AoA & ToF MUSIC Spectrum', 'NumberTitle', 'off')
	mesh(tau, theta, double(binary_peaks_pmusic))
	xlabel('Time of Flight')
	ylabel('Angle of Arrival in degrees')
	zlabel('Spectrum Peaks')
	title('AoA and ToF Estimation from Modified MUSIC Algorithm')
	grid on



	% Theta (AoA) & Tau (ToF) 3D Plot
	figure('Name', 'Selective AoA & ToF MUSIC Peaks, with only peaked AoAs', 'NumberTitle', 'off')
	mesh(tau, estimated_aoas, Pmusic(aoa_peak_indices, :))
	xlabel('Time of Flight')
	ylabel('Angle of Arrival in degrees')
	zlabel('Spectrum Peaks')
	title('AoA and ToF Estimation from Modified MUSIC Algorithm')
	grid on




	for ii = 1:1%length(estimated_aoas)
		figure_name_string = sprintf('ToF Estimation as a Function of Tau w/ AoA: %f', ...
				estimated_aoas(ii));
		figure('Name', figure_name_string, 'NumberTitle', 'off')
		plot(tau, Pmusic(ii, :), '-k')
		xlabel('Time of Flight \tau / degree')
		ylabel('Spectrum function P(\theta, \tau)  / dB')
		title(figure_name_string)
		grid on
	end

    
    % Set return values
    % AoA is now a column vector
    estimated_aoas = transpose(estimated_aoas); % L * 1
    % ToF is now a length(estimated_aoas) x length(tau) matrix, with -1 padding for unused cells
    estimated_tofs = time_peak_indices; % length(estimated_aoas) * length(tau)
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


function smoothed_csi = smooth_csi(csi)
    smoothed_csi = zeros(size(csi, 2), size(csi, 2));
    % Antenna 1 (values go in the upper left quadrant)
    m = 1;
    for ii = 1:1:15
        n = 1;
        for j = ii:1:(ii + 15)
            smoothed_csi(m, n) = csi(1, j); % 1 + sqrt(-1) * j;
            n = n + 1;
        end
        m = m + 1;
    end
    
    % Antenna 2
    % Antenna 2 has its values in the top right and bottom left
    % quadrants, the first for loop handles the bottom left, the second for
    % loop handles the top right
    
    % Bottom left of smoothed csi matrix
    for ii = 1:1:15
        n = 1;
        for j = ii:1:(ii + 15)
            smoothed_csi(m, n) = csi(2, j); % 2 + sqrt(-1) * j;
            n = n + 1;
        end
        m = m + 1;
    end
    
    % Top right of smoothed csi matrix
    m = 1;
    for ii = 1:1:15
        n = 17;
        for j = ii:1:(ii + 15)
            smoothed_csi(m, n) = csi(2, j); %2 + sqrt(-1) * j;
            n = n + 1;
        end
        m = m + 1;
    end
    
    % Antenna 3 (values go in the lower right quadrant)
    for ii = 1:1:15
        n = 17;
        for j = ii:1:(ii + 15)
            smoothed_csi(m, n) = csi(3, j); %3 + sqrt(-1) * j;
            n = n + 1;
        end
        m = m + 1;
    end
end