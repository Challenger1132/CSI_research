%% Run MUSIC algorithm with SpotFi method including ToF and AoA
% x                -- the signal matrix
% antenna_distance -- the distance between the antennas in the linear array
% frequency        -- the frequency of the signal being localized
% sub_freq_delta   -- the difference between subcarrier frequencies
% data_name        -- the name of the data file being operated on, used for labeling figures
% Return:
% estimated_aoas   -- the angle of arrivals that gave peaks from running MUSIC, as a vector
% estimated_tofs   -- the time of flights that gave peaks on the estimated_aoas from running music.
%                         This is a matrix with dimensions [length(estimated_aoas, ), length(tau)].
%                         The columns are zero padded at the ends to handle different peak counts 
%                           across different AoAs.
%                         I.E. if there are three AoAs then there will be three rows in 
%                           estimated_tofs
function [estimated_tofs, estimated_aoas] = aoa_tof_music(x, ...
        antenna_distance, frequency, sub_freq_delta, data_name, theta, tau, subcarrier_eval)
    % If OUTPUT_SUPPRESSED does not exist then initialize all the globals.
    if exist('OUTPUT_SUPPRESSED') == 0
        globals_init()
    end
    %% DEBUG AND OUTPUT VARIABLES-----------------------------------------------------------------%%
    % Debug Variables
    global DEBUG_PATHS
    global DEBUG_PATHS_LIGHT
    
    % Output Variables
    global OUTPUT_AOAS
    global OUTPUT_TOFS
    global OUTPUT_AOA_MUSIC_PEAK_GRAPH
    global OUTPUT_TOF_MUSIC_PEAK_GRAPH
    global OUTPUT_AOA_TOF_MUSIC_PEAK_GRAPH
    global OUTPUT_SELECTIVE_AOA_TOF_MUSIC_PEAK_GRAPH
    global OUTPUT_BINARY_AOA_TOF_MUSIC_PEAK_GRAPH
    global OUTPUT_SUPPRESSED
    global OUTPUT_FIGURES_SUPPRESSED
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin == 4
        data_name = '-';
    end
    % Data covarivance matrix
    R = x * x';
    % Find the eigenvalues and eigenvectors of the covariance matrix
    [eigenvectors, eigenvalue_matrix] = eig(R);
    %{
    % Find max eigenvalue for normalization
    max_eigenvalue = -1111;
    for ii = 1:size(eigenvalue_matrix, 1)
        if eigenvalue_matrix(ii, ii) > max_eigenvalue
            max_eigenvalue = eigenvalue_matrix(ii, ii);
        end
    end
    %}
    max_eigenvalue = max(max(eigenvalue_matrix));
    if DEBUG_PATHS && ~OUTPUT_SUPPRESSED
        fprintf('Normalized Eigenvalues of Covariance Matrix\n')
    end
    for ii = 1:size(eigenvalue_matrix, 1)
        eigenvalue_matrix(ii, ii) = eigenvalue_matrix(ii, ii) / max_eigenvalue;
        if DEBUG_PATHS && ~OUTPUT_SUPPRESSED
            % Suppress most print statements...
            if ii > 20
                fprintf('Index: %d, eigenvalue: %f\n', ii, eigenvalue_matrix(ii, ii))
                if ii + 1 <= size(eigenvalue_matrix, 1)
                    fprintf('Decrease Factor %f:\n', ...
                            ((eigenvalue_matrix(ii + 1, ii + 1) / max_eigenvalue) ...
                                / eigenvalue_matrix(ii, ii)))
                end
            end
        end
    end
    
    % Find the largest decrease ratio that occurs between the last 10 elements (largest 10 elements)
    % and is not the first decrease (from the largest eigenvalue to the next largest)
    % Compute the decrease factors between each adjacent pair of elements, except the first decrease
    start_index = size(eigenvalue_matrix, 1) - 2;
    end_index = start_index - 10;
    decrease_ratios = zeros(start_index - end_index + 1, 1);
    k = 1;
    for ii = start_index:-1:end_index
        temp_decrease_ratio = eigenvalue_matrix(ii + 1, ii + 1) / eigenvalue_matrix(ii, ii);
        decrease_ratios(k, 1) = temp_decrease_ratio;
        k = k + 1;
    end
    if DEBUG_PATHS_LIGHT && ~OUTPUT_SUPPRESSED
        fprintf('\n')
    end
    [max_decrease_ratio, max_decrease_ratio_index] = max(decrease_ratios);
    if DEBUG_PATHS && ~OUTPUT_SUPPRESSED
        fprintf('Max Decrease Ratio: %f\n', max_decrease_ratio)
        fprintf('Max Decrease Ratio Index: %d\n', max_decrease_ratio_index)
    end

    index_in_eigenvalues = size(eigenvalue_matrix, 1) - max_decrease_ratio_index;
    num_computed_paths = size(eigenvalue_matrix, 1) - index_in_eigenvalues + 1;
    
    if (DEBUG_PATHS || DEBUG_PATHS_LIGHT) && ~OUTPUT_SUPPRESSED
        fprintf('True number of computed paths: %d\n', num_computed_paths)
        for ii = size(eigenvalue_matrix, 1):-1:end_index
            fprintf('%g, ', eigenvalue_matrix(ii, ii))
        end
        fprintf('\n')
    end
    % Estimate noise subspace
    column_indices = 1:(size(eigenvalue_matrix, 1) - num_computed_paths);
    eigenvectors = eigenvectors(:, column_indices); 
    % Peak search
    % Angle in degrees (converts to radians in phase calculations)
    %% TODO: Tuning theta too??
    % costheta = -1:0.01:1;
    % theta = acos(costheta)/pi*180; 
    %theta = -90:90;
    % time in milliseconds
    %% TODO: Tuning tau....
    %tau = 0:(1.0 * 10^-9):(50 * 10^-9);
    %tau = 0:(100.0 * 10^-9):(3000 * 10^-9);
    
    %Pmusic_tmp = zeros(length(theta), length(tau));
    steering_matrix = compute_steering_matrix(theta, tau, frequency, ...
        sub_freq_delta, antenna_distance, subcarrier_eval);
    H = eigenvectors * eigenvectors';
    
    PP = zeros(1, size(steering_matrix, 2));
    
    for ii = 1:size(steering_matrix, 2)
        S = steering_matrix(:,ii); % 按列进行求值，也是进行了length(theta)*length(tau)次循环
        PP(ii) = S' * H * S;
    end
	% dim = length(theta)*length(tau);
    % steering_matrix = zeros(30, dim);
	% Pmusic = zeros(length(theta), length(tau));
	
    PP = wrev(PP);
    PP = reshape(PP, length(theta), length(tau));
    Pmusic = 1./abs(PP);
    Pmusic = fliplr(Pmusic);
    % Convert to decibels
    Pmusic = 10*log10(Pmusic);
    %{
    %filter out low power ToF dims
    filter_thre = -10;
    dP = diag(cov(Pmusic));
    condition = dP > filter_thre;
    tof_index = condition;
    
    %{
    if isempty(tof_index)
        filter_thre = 0.05;
        dP = diag(cov(Pmusic));
        condition = dP > filter_thre;
        tof_index = find(condition);
    end
    %}
    estimated_tofs = tau(tof_index);
    Pmusic = Pmusic(:, condition);
    % pre-reduce the same vector along tof dim
    tmp = rref(Pmusic');
    Pmusic = Pmusic(:, any(tmp, 2));
    estimated_tofs = estimated_tofs(any(tmp, 2));
    %}
    
    %{
    if OUTPUT_AOA_TOF_MUSIC_PEAK_GRAPH && ~OUTPUT_SUPPRESSED && ~OUTPUT_FIGURES_SUPPRESSED
        % Theta (AoA) & Tau (ToF) 3D Plot
        figure('Name', 'AoA & ToF MUSIC Peaks', 'NumberTitle', 'off')
        mesh(tau, theta, Pmusic)
        xlabel('Time of Flight')
        ylabel('Angle of Arrival in degrees')
        zlabel('Spectrum Peaks')
        title('AoA and ToF Estimation from Modified MUSIC Algorithm')
        grid on
    end

    if (DEBUG_PATHS || OUTPUT_AOA_MUSIC_PEAK_GRAPH) ...
            && ~OUTPUT_SUPPRESSED && ~OUTPUT_FIGURES_SUPPRESSED
        % Theta (AoA)
        figure_name_string = sprintf('%s: Number of Paths: %d', data_name, num_computed_paths);
        figure('Name', figure_name_string, 'NumberTitle', 'off')
        plot(theta, Pmusic(:, 1), '-k')
        xlabel('Angle, \theta')
        ylabel('Spectrum function P(\theta, \tau)  / dB')
        title('AoA Estimation as a function of theta')
        grid on
    end
    %}
    % subplot(1, 3, 3);
    
    
    % binary_peaks_pmusic = imregionalmax(Pmusic);
    [ix, iy] = find(imregionalmax(Pmusic));
    ind = sub2ind(size(Pmusic), ix, iy);
    % remove false positives
    fp_thre = -10;
    fp_idx = find(Pmusic(ind) < fp_thre);
    ix(fp_idx) = [];
    iy(fp_idx) = [];
    assert(~isempty(ix));
    
    %%Plot surface
    hf = figure(1);
    WinOnTop(hf);
    ind = sub2ind(size(Pmusic), ix, iy);
    surf(tau, theta, Pmusic);
    hold on;
    plot3(tau(iy), theta(ix), Pmusic(ind), 'r*', 'MarkerSize', 24)
    hold off;
    
    %%
    estimated_tofs = tau(iy);
    estimated_aoas = theta(ix);
    
end

%% Computes the steering vector for SpotFi. 
% Each steering vector covers 2 antennas on 15 subcarriers each.
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
    omega_tof = omega_tof_phase(tau, sub_freq_delta);
    phi_aoa = phi_aoa_phase(theta, freq, ant_dist);
    for ii = 1:2
        tmp = 1;
        for jj = 1:15
            steering_vector(k, 1) = base_element * tmp;
            tmp = tmp*omega_tof;
            k = k + 1;
        end
        base_element = base_element * phi_aoa;
    end
end

function steering_matrix = compute_steering_matrix(theta, tau, freq, ...
    sub_freq_delta, ant_dist, subcarrier_eval)
    dim = length(theta)*length(tau);

    steering_matrix = zeros(2*subcarrier_eval, dim);
    k = 1;
    base_element = ones(1, length(theta));
    omega_tof = omega_tof_phase(tau, sub_freq_delta);
    phi_aoa = phi_aoa_phase(theta, freq, ant_dist);
    for ii = 1:2
        tmp = ones(1, length(tau));
        for jj = 1:subcarrier_eval
            steering_matrix(k, :) = reshape(base_element' * tmp, 1, dim);
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

