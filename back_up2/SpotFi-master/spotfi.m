%% Runs the SpotFi test over the passed in data files which each contain CSI data for many packets
% csi_trace        -- the csi_trace for several packets
% frequency        -- the base frequency of the signal
% sub_freq_delta   -- the difference between adjacent subcarriers
% antenna_distance -- the distance between each antenna in the array, measured in meters
% data_name        -- a label for the data which is included in certain outputs

%Write by Joey
%aoa_packet_data:每个数据包的aoa，即从每个数据包的music频谱得到的波峰对应的aoa
%tof_packet_data:每个数据包的tof，即从每个数据包的music频谱得到的波峰对应的tof
%output_top_aoaos:前5个最有可能是直达路径的AOA
function [aoa_packet_data,tof_packet_data,output_top_aoas, Pmusics, likelihood, likelihood_test] = spotfi(csi_trace, frequency, sub_freq_delta, antenna_distance, data_name)
    % csi_trace是 cell(n, 1);
	
	if nargin < 5
        data_name = ' - ';
    end
    
    num_packets = length(csi_trace);
    % Loop over packets, estimate AoA and ToF from the CSI data for each packet
    aoa_packet_data = cell(num_packets, 1); %和传入csi_trace 一样大小的 cell
    tof_packet_data = cell(num_packets, 1);
	Pmusics = cell(num_packets, 1);
    packet_one_phase_matrix = 0;

    % Do computations for packet one so the packet loop can be parallelized
    % Get CSI for current packet
    csi_entry = csi_trace{1};
    csi = get_scaled_csi(csi_entry);  %这里的csi是以絶対単位进行度量的 计算信道矩阵H
    % Only consider measurements for transmitting on one antenna
    csi = csi(1, :, :);  %考虑发送端的1天线，接收端还是3天线
    % Remove the single element dimension
    csi = squeeze(csi);  % 3*30

    % Sanitize ToFs with Algorithm 1
    packet_one_phase_matrix = unwrap(angle(csi), pi, 2);  %按行进行，消除相位跳变
    sanitized_csi = spotfi_algorithm_1(csi, sub_freq_delta);
    % Acquire smoothed CSI matrix
    smoothed_sanitized_csi = smooth_csi(sanitized_csi);  % smoothed_sanitized_csi 30*32
	%smoothed_sanitized_csi进行了线性拟合，并且进行了空间平滑，可以进行music算法
    % Run SpotFi's AoA-ToF MUSIC algorithm on the smoothed and sanitized CSI matrix
    [aoa_packet_data{1}, tof_packet_data{1}, Pmusics{1}] = aoa_tof_music(...
            smoothed_sanitized_csi, antenna_distance, frequency, sub_freq_delta, data_name);
    fprintf('1\n');
	% 假设拥有p个AOA峰值，那么 estimated_aoas 是 p * 1
	% TOF 是 p * length(tau) 的矩阵  ---- 每一个包就会返回这个的AOA向量，以及TOF矩阵
	
    %% TODO: REMEMBER THIS IS A PARFOR LOOP, AND YOU CHANGED THE ABOVE CODE AND THE BEGIN INDEX
    parfor (packet_index = 2:num_packets, 4)
        % Get CSI for current packet
        csi_entry = csi_trace{packet_index}; % 得到以绝对单位的CSI
        csi = get_scaled_csi(csi_entry);
        % Only consider measurements for transmitting on one antenna
        csi = csi(1, :, :);
        % Remove the single element dimension
        csi = squeeze(csi);

        % Sanitize ToFs with Algorithm 1
        sanitized_csi = spotfi_algorithm_1(csi, sub_freq_delta, packet_one_phase_matrix);
        % Acquire smoothed CSI matrix
        smoothed_sanitized_csi = smooth_csi(sanitized_csi);
        % Run SpotFi's AoA-ToF MUSIC algorithm on the smoothed and sanitized CSI matrix
        [aoa_packet_data{packet_index}, tof_packet_data{packet_index}, Pmusics{packet_index}] = aoa_tof_music(...
                smoothed_sanitized_csi, antenna_distance, frequency, sub_freq_delta, data_name);
        fprintf('%d\n',packet_index);
    end % aoa_packet_data中每一个元素是 一个AOA向量
		% tof_packet_data中每一个元素是 一个TOF矩阵

		%--------------------------------------------	
	fprintf('plot figure for Pmusic 1\n');
	pmusic1 = Pmusics{1};
	theta = -90:1:90; 
    tau = 0:(1.0 * 10^-9):(100 * 10^-9);
	[x,y] = meshgrid(theta, tau);
    figure(1);
    mesh(x,y,pmusic1');   %做出来的是角度和时延的三维图像
    xlabel('AoA');
    ylabel('ToF');
    xlim([-90 90]);
	colorbar;
	%--------------------------------------------	
	fprintf('plot figure for Pmusic 20\n');
	pmusic10 = Pmusics{15};
	theta = -90:1:90; 
    tau = 0:(1.0 * 10^-9):(100 * 10^-9);
	[x,y] = meshgrid(theta, tau);
    figure(2);
    mesh(x,y,pmusic10');   %做出来的是角度和时延的三维图像
    xlabel('AoA');
    ylabel('ToF');
    xlim([-90 90]);
    colorbar;
	%--------------------------------------------		
		
    % Find the number of elements that will be in the full_measurement_matrix
    % The value must be computed since each AoA may have a different number of ToF peaks
    % Packet Loop
    fprintf('packet loop\n');
	
	full_measurement_matrix_size = 0;
    for packet_index = 1:num_packets %-------------对所有包----------
        tof_matrix = tof_packet_data{packet_index};
        aoa_matrix = aoa_packet_data{packet_index};
        % AoA Loop  %-------------对一个包----------
        for j = 1:size(aoa_matrix, 1) % AOA矩阵的行数 其实只有一列  
            % ToF Loop
            for k = 1:size(tof_matrix(j, :), 2)  % TOF矩阵的第 j 行  列数
                % Break once padding is hit
                if tof_matrix(j, k) < 0  % padding = -1 一旦遇到填充值，就break
                    break
                end
                full_measurement_matrix_size = full_measurement_matrix_size + 1;
            end
        end %-------------对一个包----------
    end  %-------------对所有包---------------------------------------------
	
	full_measurement_matrix_size_test = 0;
	for packet_index = 1:num_packets %-------------对所有包----------
        tof_matrix = tof_packet_data{packet_index};
        temp = tof_matrix >= 0;
		len = sum(sum(temp));
		full_measurement_matrix_size_test = full_measurement_matrix_size_test + len;
    end  %-------------对所有包---------------------------------------------
	
	fprintf('full_measurement_matrix_size = %d\n', full_measurement_matrix_size);
	fprintf('full_measurement_matrix_size_test = %d\n', full_measurement_matrix_size_test);
	%================================================================
	
	
    % Construct the full measurement matrix
    full_measurement_matrix = zeros(full_measurement_matrix_size, 2);
    full_measurement_matrix_index = 1;
    % Packet Loop
    for packet_index = 1:num_packets
        tof_matrix = tof_packet_data{packet_index};
        aoa_matrix = aoa_packet_data{packet_index};
        % AoA Loop
        for j = 1:size(aoa_matrix, 1)
            % ToF Loop
            for k = 1:size(tof_matrix(j, :), 2)
                % Break once padding is hit
                if tof_matrix(j, k) < 0
                    break
                end
                full_measurement_matrix(full_measurement_matrix_index, 1) = aoa_matrix(j, 1);
                full_measurement_matrix(full_measurement_matrix_index, 2) = tof_matrix(j, k);
                full_measurement_matrix_index = full_measurement_matrix_index + 1;
            end  
        end
    end
	
			%同一个角度对应的不同的时间，同一个角度对应的不同的时间
			% each AoA may have a different number of ToF peaks
			% AOA1  TOF1
			% AOA1  TOF2
			% AOA1  TOF3
			% AOA1  TOF4
			% AOA1  TOF5
			% AOA1  TOF6
			% AOA1  TOF7
			% AOA1  TOF8
			% AOA2  TOF1
			% AOA2  TOF2
			% AOA2  TOF3
			% AOA2  TOF4
			% AOA2  TOF5
			% AOA2  TOF6
			% AOA2  TOF7
			% AOA2  TOF8
			% .....

    % Normalize AoA & ToF
    fprintf('Normalize AoA &ToF\n');
    aoa_max = max(abs(full_measurement_matrix(:, 1)));  %第一列中最大值
    tof_max = max(abs(full_measurement_matrix(:, 2)));  %第二列中最大值
    full_measurement_matrix(:, 1) = full_measurement_matrix(:, 1) / aoa_max;
    full_measurement_matrix(:, 2) = full_measurement_matrix(:, 2) / tof_max;  %归一化

    % Cluster AoA and ToF for each packet
    % Worked Pretty Well
    fprintf('Clustering\n');
    [cluster_indices,clusters] = aoa_tof_cluster(full_measurement_matrix);

    % Delete outliers from each cluster
    fprintf('delete outliers\n');
    for ii = 1:size(clusters, 1)
        % Delete clusters that are < 5% of the size of the number of packets
		% 小于5%包总数量的 cluster会被移除
        if size(clusters{ii}, 1) < (0.05 * num_packets)
            clusters{ii} = [];
            cluster_indices{ii} = [];
            continue;
        end
        alpha = 0.05;  %显著性水平
        [~, outlier_indices, ~] = deleteoutliers(clusters{ii}(:, 1), alpha); %rep = 0;不保留NAN
		%返回异常值在 clusters{ii}(:, 1) 中的下标
        cluster_indices{ii}(outlier_indices(:), :) = []; % cluster_indices{ii}中异常值所在的行被删掉
        clusters{ii}(outlier_indices(:), :) = [];  %异常值从cluster中移除

        alpha = 0.05;
        [~, outlier_indices, ~] = deleteoutliers(clusters{ii}(:, 2), alpha);
        cluster_indices{ii}(outlier_indices(:), :) = [];
        clusters{ii}(outlier_indices(:), :) = [];
    end

    %% TODO: Tune parameters
    %% TODO: Tuning parameters using SVM results
    % Good base: 5, 10000, 75000, 0 (in order)
    % Likelihood parameters
    fprintf('likelihood\n');
    weight_num_cluster_points = 0.0001 * 10^-3;
    weight_aoa_variance = -0.7498 * 10^-3;
    weight_tof_variance = 0.0441 * 10^-3;
    weight_tof_mean = -0.0474 * 10^-3;
    constant_offset = -1;
    %{
    weight_num_cluster_points = 5;
    weight_aoa_variance = 50000; % prev = 10000; prev = 100000;
    weight_tof_variance = 100000;
    weight_tof_mean = 1000; % prev = 50; % prev = 10;
    %}
    %constant_offset = 300;
    % Compute likelihoods
	likelihood_test = zeros(length(clusters), 1);
	cluster_aoa_test = zeros(length(clusters), 1);
	
	
    likelihood = zeros(length(clusters), 1);
    cluster_aoa = zeros(length(clusters), 1);
    max_likelihood_index = -1;
    top_likelihood_indices = [-1; -1; -1; -1; -1;]; % 前5个最大的似然值
	
	
    for ii = 1:length(clusters)
        % Ignore clusters of size 1
        if size(clusters{ii}, 1) == 0
            continue
        end
        % Initialize variables
        num_cluster_points = size(clusters{ii}, 1);  % 第ii个簇中点的个数
        aoa_mean = 0;
        tof_mean = 0;
        aoa_variance = 0;
        tof_variance = 0;
        % Compute Means 
        for jj = 1:num_cluster_points
            aoa_mean = aoa_mean + clusters{ii}(jj, 1);  
            tof_mean = tof_mean + clusters{ii}(jj, 2);  
        end
        aoa_mean = aoa_mean / num_cluster_points;  %求第ii个簇中 AOA均值
        tof_mean = tof_mean / num_cluster_points;  %求第ii个簇中 TOF均值
		
        % Compute Variances
        for jj = 1:num_cluster_points
            aoa_variance = aoa_variance + (clusters{ii}(jj, 1) - aoa_mean)^2;
            tof_variance = tof_variance + (clusters{ii}(jj, 2) - tof_mean)^2;
			% (clusters{ii}(jj, 1) 是第ii个簇中的第一列代表AOA，第jj个AOA
        end
        aoa_variance = aoa_variance / (num_cluster_points - 1);  % N - 1 是无偏估计
        tof_variance = tof_variance / (num_cluster_points - 1);
		
		
		%{
		aoa_mean_test = mean(clusters{ii}(:, 1));
		tof_mean_test = mean(clusters{ii}(:, 2));
		aoa_variance_test = var(clusters{ii}(:,1));
        tof_variance_test = var(clusters{ii}(:,2));
		%}
		
        % Compute Likelihood
        %% TODO: Trying result from SVM
        %{
        exp_body = weight_num_cluster_points * num_cluster_points ...
                - weight_aoa_variance * aoa_variance ...
                - weight_tof_variance * tof_variance ...
                - weight_tof_mean * tof_mean ...
                - constant_offset;
        %}
		% 第K个路径是LOS的概率
		%{
        exp_body = weight_num_cluster_points * num_cluster_points ...
                + weight_aoa_variance * aoa_variance ...
                + weight_tof_variance * tof_variance ...
                + weight_tof_mean * tof_mean ...
                + constant_offset;
				
		exp_body_test = weight_num_cluster_points * num_cluster_points ...
                + weight_aoa_variance * aoa_variance_test ...
                + weight_tof_variance * tof_variance_test ...
                + weight_tof_mean * tof_mean_test ...
                + constant_offset;
				
        likelihood(ii, 1) = exp_body; %exp(exp_body);
		likelihood_test(ii, 1) = 0;
		%}
        % Compute Cluster Average AoA
        for jj = 1:size(clusters{ii}, 1)  %第ii个簇的大小
            cluster_aoa(ii, 1) = cluster_aoa(ii, 1) + aoa_max * clusters{ii}(jj, 1); %第jj个AOA
        end  % 每个簇中所有AOA的和
        cluster_aoa(ii, 1) = cluster_aoa(ii, 1) / size(clusters{ii}, 1);  % 每个簇中所有AOA的和，求均值 
		
		cluster_aoa_test(ii, 1) = aoa_mean * aoa_max;
		
        % Check for maximum likelihood
        if max_likelihood_index == -1 ...
                || likelihood(ii, 1) > likelihood(max_likelihood_index, 1)
            max_likelihood_index = ii;  %这样会找出 max_likelihood_index
        end
        % Record the top maximum likelihoods
        for jj = 1:size(top_likelihood_indices, 1) % 5
            % Replace empty slot
            if top_likelihood_indices(jj, 1) == -1
                top_likelihood_indices(jj, 1) = ii;
                break;
            % Add somewhere in the list
            elseif likelihood(ii, 1) > likelihood(top_likelihood_indices(jj, 1), 1)
                % Shift indices down
                for kk = size(top_likelihood_indices, 1):-1:(jj + 1)
                    top_likelihood_indices(kk, 1) = top_likelihood_indices(kk - 1, 1);
                end
                top_likelihood_indices(jj, 1) = ii;
                break;
            % Add an extra item to the list because the likelihoods are all equal...
            elseif likelihood(ii, 1) == likelihood(top_likelihood_indices(jj, 1), 1) ...
                    && jj == size(top_likelihood_indices, 1)
                top_likelihood_indices(jj + 1, 1) = ii;
                break;
            end
        end
    end
    % Select AoA
    fprintf('select AoA\n');
    max_likelihood_average_aoa = cluster_aoa(max_likelihood_index, 1);
    % Profit
    temp = find(top_likelihood_indices~=-1);
    top_likelihood_indices = top_likelihood_indices(temp);
    output_top_aoas = cluster_aoa(top_likelihood_indices);
	fprintf('max_likelihood_average_aoa = %d\n', max_likelihood_average_aoa);
end