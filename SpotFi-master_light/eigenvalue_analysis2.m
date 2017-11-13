function [pathIndex2] = eigenvalue_analysis2(eigenval)

	len = length(eigenval);
	pathIndex2 = zeros(len, 1);
	for ii = 1 : len
		eigenvalue = eigenval{ii};
		[sorted_eigval, index] = sort(eigenvalue, 'descend');
		M = length(eigenvalue);
		
		Delta_lambda_1 = zeros(M-1, 1);
		for i = 1 : M-1;
			Delta_lambda_1(i) = sorted_eigval(i) / sorted_eigval(i+1);
		end
		[~, pathsindex] = max(Delta_lambda_1);
		pathIndex2(ii) = pathsindex;
end
