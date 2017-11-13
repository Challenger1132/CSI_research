function eigenvectors = noise_space_eigenvectors(x)
	% x = smoothed_sanitized_csi 30*32
    % Data covariance matrix
    R = x * x'; 
    % Find the eigenvalues and eigenvectors of the covariance matrix
    [eigenvectors, eigenvalue_matrix] = eig(R); %R M*M
    % Find max eigenvalue for normalization
    max_eigenvalue = -1111;
    for ii = 1:size(eigenvalue_matrix, 1)  
        if eigenvalue_matrix(ii, ii) > max_eigenvalue
            max_eigenvalue = eigenvalue_matrix(ii, ii);
        end
    end %遍历对角阵上每一个特征值，并找最大的特征值max_eigenvalue
    for ii = 1:size(eigenvalue_matrix, 1) 
        eigenvalue_matrix(ii, ii) = eigenvalue_matrix(ii, ii) / max_eigenvalue;
    end %所有特征值都除以最大特征值，进行归一化
    
    % Find the largest decrease ratio that occurs between the last 10 elements (largest 10 elements)
    % and is not the first decrease (from the largest eigenvalue to the next largest)
    % Compute the decrease factors between each adjacent pair of elements, except the first decrease
	
	% 求出了R的特征值对应的特征向量，如何确定Ne个最小特征值的个数，最小特征值是Ne重的
	% 也就是对信号空间和噪声空间进行合理的划分，划分的优劣影响角度的估计 **
	
    start_index = size(eigenvalue_matrix, 1) - 2;  % 28
    end_index = start_index - 10; %18
    decrease_ratios = zeros(start_index - end_index + 1, 1); % 11
    k = 1;
    for ii = start_index:-1:end_index % 28 27 26 25 ... 19 18
        temp_decrease_ratio = eigenvalue_matrix(ii + 1, ii + 1) / eigenvalue_matrix(ii, ii);
        decrease_ratios(k, 1) = temp_decrease_ratio;
        k = k + 1;
    end
	
    [max_decrease_ratio, max_decrease_ratio_index] = max(decrease_ratios); %下降率最大的值
    index_in_eigenvalues = size(eigenvalue_matrix, 1) - max_decrease_ratio_index;  % 30 - ？
    num_computed_paths = size(eigenvalue_matrix, 1) - index_in_eigenvalues + 1;
    % 估计多径的数目，计算信号空间以及噪声子空间，噪声空间和导向矢量是相互正交的
    % Estimate noise subspace
    column_indices = 1:(size(eigenvalue_matrix, 1) - num_computed_paths);
    eigenvectors = eigenvectors(:, column_indices);  % 取出噪声子空间 
end