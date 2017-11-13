

function linear_fit_csi_phase = linear_fit(csi)
	% csi 是3 * 30的数据
	NT = numel(csi);  % 90
	M = size(csi, 1);  % 3
	N = size(csi, 2);  % 30
	col1 = ones(NT, 1);  % 90 * 1
	col2 = repmat((0:1:(N-1))', M, 1);
	A = [col1, col2]; % 90 * 2
	b = reshape(csi, numel(csi), 1); % 90 * 1
	temp1 = A'*A;
	temp2 = A'*b;
	X = linsolve(A'*A, A'*b);
	% beta = X(1);
	rho = X(2);
	rs_col2 = reshape(col2, 30, 3);
	phase_matrix = csi - rs_col2'*rho;
	R = abs(csi);
	csi_matrix = R .* exp(1i * phase_matrix);
	linear_fit_csi_phase = unwrap(angle(csi_matrix).');
end