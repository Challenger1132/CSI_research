filepath = '3.0-75-4.dat';
[Pmusics, eigenvalue] = run_spotfi(filepath);	
	
	pathIndex1 = eigenvalue_analysis2(eigenvalue);
	figure('Name', 'eigenvalue analysis', 'NumberTitle', 'off');
	for ii = 1 : length(eigenvalue)
		data = eigenvalue{ii};
		data = sort(data, 'descend');
		
		x = 1 : length(data);
		plot(x', data);
		grid on; hold on;
		paths = pathIndex1(ii);
		%plot(paths, data(paths), 'o', 'MarkerSize', 10);
		%hold on;
	end

