%% 单个图像绘制出来和phase_analysis_1.m一样
clc;clear all;
csi_trace = read_bf_file('3.0-30-3.dat');
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
csi_matrix1 = csis{index+1}; % 30*3
flag1 = 0; flag2 = 1; flag3 = 1; flag4 = 1; flag5 = 1;
mcsi_matrix = linear_transform_qh(csi_matrix'); % input 3*30
mcsi_matrix1 = linear_transform_qh(csi_matrix1'); % input 3*30
%% plot origin CSI phase
if flag1
    figure('Name', 'origin CSI phase');
    origin_csi_phase = angle(csi_matrix);
    plot(origin_csi_phase);
    grid on;
    title('origin CSI phase');
end
%% plot unwrapd CSI phase
if flag2 
    figure('Name', 'unwrapd CSI phase');
    unwrapd_csi = unwrap(angle(csi_matrix), pi, 1);
    plot(unwrapd_csi);
    grid on;hold on;
    unwrapd_csi1 = unwrap(angle(csi_matrix1), pi, 1);
    plot(unwrapd_csi1);
    grid on;
    title('unwrapd CSI phase');
end
%% plot unwrapd CSI phase difference
if flag3
    figure('Name', 'CSI phase difference ');
    pdifference = unwrapd_csi - unwrapd_csi1;
    plot(pdifference);
    grid on;
    title('CSI phase difference');
end
%% plot CSI phase with linear transform
if flag4
    figure('Name', 'CSI phase with linear transform');
    mcsiphase = angle(mcsi_matrix');
    plot(mcsiphase);
    grid on; hold on;
    mcsiphase1 = angle(mcsi_matrix1');
    plot(mcsiphase1);
    title('CSI phase with linear transform');
end
%% plot CSI phase diference with linear transform
if flag5
    figure('Name', 'CSI phase diference with linear transform');
    pdifference = mcsiphase - mcsiphase1;
    plot(pdifference);
    grid on;
    title('CSI phase diference with linear transform');
end