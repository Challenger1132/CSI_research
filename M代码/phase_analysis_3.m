%% 绘制极坐标图像，30*3 --> 90*1，3天线排列
% 分别CSI数据的求幅度和相位，然后polar(theta, rho);

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
numberpackages = 60;
gap = 15;
csi_data = zeros(90, numberpackages);
csi_data_linear_transform = zeros(90, numberpackages);
for ind = 1:numberpackages
    index = ind + gap;
    csi = csis{index};
    csi_temp = reshape(csi, 90, 1);
    csi_data(:, ind) = csi_temp;
end
csi_amp = abs(csi_data);
csi_phase = angle(csi_data);
%%
for ind = 1:numberpackages
    index = ind + gap;
    csi = csis{index}; % 30*3
    csi_matrix = linear_transform_qh(csi'); % 3*30
    csi_temp = reshape(csi_matrix', 90, 1);
    csi_data_linear_transform(:, ind) = csi_temp;
end
csi_amp_linear = abs(csi_data_linear_transform);
csi_phase_linear = angle(csi_data_linear_transform);
%%
figure('Name', 'raw CSI phase');
polar(csi_phase, csi_amp, 'b*');
hold on;
title('raw CSI phase');
%%
polar(csi_phase_linear, csi_amp_linear, 'r*');
hold off;
title('CSI phase with linear transform');
grid off;
