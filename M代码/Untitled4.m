%% read file
clc;clear all;
csi_trace = read_bf_file('1.5-45-3.dat');
num_package = length(csi_trace);
fprintf('mumber_package = %d\n', num_package);
cirs = cell(num_package, 1);
csis = cell(num_package, 1);
%%
for ii = 1:num_package
    csi_entry = csi_trace{ii};
    temp = get_scaled_csi(csi_entry);
    temp = temp(1, :, :);
    csis{ii} = squeeze(temp).'; % 30*3
end
for ii = 1: length(csis)
    csi = csis{ii}; % 30 * 3
    cirs{ii} = abs(ifft(csi));
end
%%
index = 10;
csi_matrix = csis{index}; % 30*3
