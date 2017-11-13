clusters = cell(2, 1);
figure(1);
for ii = 1 : 2
	points = round(rand()*20);
	clusters{ii} = round(rand(points, 2)*(10 + ii^8));
end
for ii = 1 : num_of_cluster
	datax = clusters{ii}(:, 1);
	datay = clusters{ii}(:, 2);
	scatter(datax, datay);
	hold on;
end
xlabel('tof');
ylabel('AOA');
grid on;