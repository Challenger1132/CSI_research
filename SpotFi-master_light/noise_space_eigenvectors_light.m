function eigenvectors = noise_space_eigenvectors_light(x)
	% x = smoothed_sanitized_csi 30*32

    R = x * x';  % 原始方式先平滑，再求协方差矩阵
	% R = x;  % 先求协方差矩阵，平滑，最后直接处理矩阵
    [eigenvectors, eigenvalue_matrix] = eig(R); %R M*M
	
	eigenvalues = diag(eigenvalue_matrix);
	[eigenvalues, index] = sort(eigenvalues, 'descend');
	eigenvectors = eigenvectors(:, index);
	
	M = size(R, 1);
	Delta_lambda = zeros(M-1, 1);
	for i = 1 : M-1;
		Delta_lambda(i) = sorted_eigval(i) - sorted_eigval(i+1);
	end
	[~, pathsindex] = max(Delta_lambda);
	paths = pathsindex;
	eigenvectors = eigenvectors(:, paths+1 : M);
	
	
	
	Delta_lambda_1 = zeros(M-1, 1);
	for i = 1 : M-1;
		Delta_lambda_1(i) = sorted_eigval(i) / sorted_eigval(i+1);
	end
	[~, pathsindex] = max(Delta_lambda_1);
	paths_1 = pathsindex;
	eigenvectors = eigenvectors(:, paths_1+1 : M);
	
	figure(Name, 'plot eigenvalues......');
	plot(1:M, eigenvalues);
	hold on;
	plot(paths, 0, 'bo','MarkerSize',12);
	hold on;
	plot(paths_1, 0, 'ro','MarkerSize',12);
	
	
	
end