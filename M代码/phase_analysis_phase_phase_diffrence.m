%% subplot图像绘制出来和phase_analysis.m一样
clc;clear all;
csi_trace = read_bf_file('4.0-15r-5.dat');
num_package = length(csi_trace);
fprintf('mumber_package = %d\n', num_package);
cirs = cell(num_package, 1);
csis = cell(num_package, 1);
%%
for ii = 1:num_package
    csi_entry = csi_trace{ii};
    temp = get_scaled_csi(csi_entry);
    temp = temp(1, :, :);
    temp = squeeze(temp);
    temp = temp([1 3 2], :);
    csis{ii} = temp.'; % 30*3
end
for ii = 1: length(csis)
    csi = csis{ii}; % 30 * 3
    cirs{ii} = abs(ifft(csi));
end
%%
index = 10;
csi_matrix = csis{index}; % 30*3
csi_matrix1 = csis{index+1}; % 30*3
flag1 = 0;
delta_f = (40 * 10^6) / 30;
 [mcsi_matrix, mcsiphase00] = linear_transform_qh(csi_matrix'); % input 3*30
 [mcsi_matrix1, mcsiphase11] = linear_transform_qh(csi_matrix1'); % input 3*30 linear_transform
% [mcsi_matrix, mcsiphase00] = linear_transform_monalisa(csi_matrix'); % input 3*30
% [mcsi_matrix1, mcsiphase11] = linear_transform_monalisa(csi_matrix1'); % input 3*30 linear_transform_monalisa failure....
% [mcsi_matrix, mcsiphase00] = linear_fit_spotifi(csi_matrix.', delta_f); % input 3*30  
% [mcsi_matrix1, mcsiphase11] = linear_fit_spotifi(csi_matrix1.', delta_f); % input 3*30 linear_fit_spotifi
% [mcsi_matrix, mcsiphase00]  = linear_fit(csi_matrix.');
% [mcsi_matrix1, mcsiphase11]  = linear_fit(csi_matrix1.');
%% plot origin CSI phase
if flag1
    figure('Name', 'origin CSI phase');
    origin_csi_phase = angle(csi_matrix);
    plot(origin_csi_phase);
    grid on;
    title('origin CSI phase');
end
%% plot CSI phase
figure('Name', 'CSI phase with linear transformation');
unwrapd_csi = unwrap(angle(csi_matrix), pi, 1);
subplot(221); plot(unwrapd_csi, ':', 'DisplayName', 'First package');
grid on; hold on;
unwrapd_csi1 = unwrap(angle(csi_matrix1), pi, 1);
plot(unwrapd_csi1, 'DisplayName', 'Second package');
hold off;
title('unwrapped CSI phase');
legend('show');
%% plot unwrapped CSI phase difference
pdifference = unwrapd_csi - unwrapd_csi1;
subplot(222); plot(pdifference);
grid on;
title('CSI phase difference');
%% plot CSI phase with linear transformation
mcsiphase = unwrap(angle(mcsi_matrix.'), pi, 1);
subplot(223); plot(mcsiphase, ':');
grid on; hold on;
mcsiphase1 = unwrap(angle(mcsi_matrix1.'), pi, 1);
plot(mcsiphase1);
title('CSI phase with linear transformation');
%% plot CSI phase diference with linear transform
pdifference = mcsiphase - mcsiphase1;
subplot(224); plot(pdifference);
grid on;
title('CSI phase diference with linear transformation');
%% plot phase directly from phase_matrix
figure('Name', 'plot phase directly from phase_matrix');
subplot(211); plot(mcsiphase00.', ':');
grid on; hold on;
plot(mcsiphase11.');
title('CSI phase with linear transformation');
%% plot CSI phase diference with linear transform
pdifference = mcsiphase00.' - mcsiphase11.';
subplot(212); plot(pdifference);
grid on;
title('plot phase directly from phase_matrix');