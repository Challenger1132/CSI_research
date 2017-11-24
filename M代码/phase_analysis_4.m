%% 
% 绘制极坐标图像，30*3 --> 90*1，3天线排列
% 分别CSI数据的求幅度和相位，然后polar(theta, rho);
% 绘制幅度和相位的热力图
% failure....
clc;clear all;
csi_trace = read_bf_file('3.0-30-3.dat');
num_package = length(csi_trace);
fprintf('mumber_package = %d\n', num_package);
csis = cell(num_package, 1);
%%
for ii = 1:num_package
    csi_entry = csi_trace{ii};
    temp = get_scaled_csi(csi_entry);
    temp = temp(1, :, :);
    csis{ii} = squeeze(temp).'; % 30*3
end
%%
numpackages = 200;
subcarrier_num = 10;
gap = 15;
csi_data = zeros(3, numpackages);
for ind = 1:numpackages
    csi = csis{ind};  % specific package data 30*3
    csi_temp = csi(subcarrier_num, :); % 取出数据的第subcarrier_num行，某个频率的子载波，包含3天线的数据 1*3
    csi_data(:, ind) = csi_temp';
end
result_csi = reshape(csi_data, 3*numpackages, 1);

csi_phase = angle(result_csi);

csi_amp = abs(result_csi);
% HeatMap(csi_phase, csi_amp);
sz = 25;
scatter(csi_amp, csi_phase, sz, 'filled');









