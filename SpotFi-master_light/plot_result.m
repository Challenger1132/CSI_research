%{
对得到的Pmusic矩阵绘制3维图像
%}







function plot_result(Pmusics, theta, tau, package_index)
	if nargin < 2
		theta = -90:1:90;
		%tau = (-100 * 10^-9):(1.0 * 10^-9):(100 * 10^-9);
		tau = 0:(1.0 * 10^-9):(100 * 10^-9);
		package_index = 10;
	end
	
	fprintf('plot figure for Pmusic 1\n');
	pmusic1 = Pmusics{package_index};
	[x, y] = meshgrid(theta, tau);
    figure('Name', 'package one');
    mesh(x, y, pmusic1.');
	xlabel('AoA');
    ylabel('ToF');
    xlim([-90 90]);
	%--------------------------------------------	
	
	fprintf('plot figure for Pmusic 20\n');
	pmusic10 = Pmusics{package_index + 1};
	[x,y] = meshgrid(theta, tau);
    figure('Name', 'package two');
    mesh(x,y,pmusic10.');
	xlabel('AoA');
    ylabel('ToF');
    xlim([-90 90]);
end