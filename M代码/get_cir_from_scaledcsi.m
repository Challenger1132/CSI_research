function cir = get_cir_from_scaledcsi(scaledcsi, num_antenna)
%	csi = scaledcsi(1, :, :); %取出发�?端第�?��天线的CSI
%   csi = squeeze(csi);  % 3* 30
	csi = scaledcsi;
	cir = zeros(3,30);
	for index = 1:size(csi, 1);
		temp = csi(index, :);
		cir(index, :) = abs(ifft(temp));
	end
	plot_data = cir([1:num_antenna], :);
	bar(1:30, plot_data');
	axis([1,30,0,35]);
    set(gca, 'XTick', 1:30);
    title('\bfAmplitude_Delay');
    xlabel('\bfDelay');
    ylabel('\bfAmplitude');
end