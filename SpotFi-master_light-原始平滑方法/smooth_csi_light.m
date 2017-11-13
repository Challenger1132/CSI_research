
% 双向空间平滑算法的实现
% 先求接收数据的协方差矩阵，然后再对协方差矩阵进行平滑，最后对平滑后的协方差矩阵进行分解
% 另一种方法是先对接收数据进行平滑，然后再求协方差矩阵，然后进行矩阵分解
function smoothed_csi = smooth_csi_light(csi)
	% 3*30
	len1 = size(csi, 1);
	len2 = size(csi, 2);
	x = reshape(csi', len1*len2, 1);
	csi = x*x';  % 90*90
	m = 30;
	crs = mssp(csi, m);
	smoothed_csi = crs;
end

function crs = mssp(cr, m)
% modified spatial smoothing
% modified spatial smoothing
%{
	M是阵元数
	m是子阵阵元数目
	p是子阵数目
%}
	[M,MM] = size(cr);
	p = M - m + 1;
	J = fliplr(eye(M));
	crfb = (cr + J*cr.'*J)/2;  % 书本公式中 不是转置而是共轭
	crs = zeros(m,m);
	for in =1:p
	  crs = crs + crfb(in:in+m-1,in:in+m-1);
	end
	crs = crs / p;
end
%End mssp.m