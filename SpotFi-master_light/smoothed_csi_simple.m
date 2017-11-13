function smoothed_csi_simple = smooth_csi(csi)
	smoothed_csi_simple = zeros(30, 32);
	for i = 115
		smoothed_csi_simple(i, [1 16]) = csi(1, [i  i + 15]);
	end

	for i = 115
		smoothed_csi_simple(i, [17  32]) = csi(2, [i  i + 15]);
		smoothed_csi_simple(i + 15, [1 16]) = csi(2, [i  i + 15]);
	end
	for i = 115
		smoothed_csi_simple(i + 15, [17  32]) = csi(3, [i  i + 15]);
	end
end