
csi = round(100*rand(3, 30));
csi_smooth = zeros(30, 32);
for i = 1:15
	csi_smooth(i, [1: 16]) = csi(1, [i : i + 15]);
end

for i = 1:15
	csi_smooth(i, [17 : 32]) = csi(2, [i : i + 15]);
	csi_smooth(i + 15, [1: 16]) = csi(2, [i : i + 15]);
end
	
for i = 1:15
	csi_smooth(i + 15, [17 : 32]) = csi(3, [i : i + 15]);
end