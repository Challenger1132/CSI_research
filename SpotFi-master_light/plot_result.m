function plot_result(Pmusics)
	fprintf('plot figure for Pmusic 1\n');
	pmusic1 = Pmusics{15};
	theta = -90:1:90; 
    tau = 0:(1.0 * 10^-9):(100 * 10^-9);
	[x,y] = meshgrid(theta, tau);
    figure(1);
    mesh(x,y,pmusic1'); %做出来的是角度和时延的三维图像
    xlabel('AoA');
    ylabel('ToF');
    xlim([-90 90]);
	%--------------------------------------------	
	
	fprintf('plot figure for Pmusic 20\n');
	pmusic10 = Pmusics{10};
	theta = -90:1:90; 
    tau = 0:(1.0 * 10^-9):(100 * 10^-9);
	[x,y] = meshgrid(theta, tau);
    figure(2);
    mesh(x,y,pmusic10');   %做出来的是角度和时延的三维图像
    xlabel('AoA');
    ylabel('ToF');
    xlim([-90 90]);
end