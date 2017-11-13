function [pathIndex1] = eigenvalue_analysis(eigenval)

	len = length(eigenval);
	pathIndex1 = zeros(len, 1);
	for ii = 1 : len
		eigenvalue = eigenval{ii};
		[sorted_eigval, index] = sort(eigenvalue, 'descend');
		M = length(eigenvalue);
		
		
		Delta_lambda = zeros(M-1, 1);
		for i = 1 : M-1;
			Delta_lambda(i) = sorted_eigval(i) - sorted_eigval(i+1);
		end
		[~, pathsindex] = max(Delta_lambda);
		pathIndex1(ii) = pathsindex;
		
end
