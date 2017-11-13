%% 分析lgtm源码线性拟合部分
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
csi_matrix1 = csis{index+1}; % 30*3
delta_f = 40 / 30;
[mcsi_matrix, phase_matrix] = spotfi_algorithm_1(csi_matrix', delta_f);
[mcsi_matrix1, phase_matrix1] = spotfi_algorithm_1(csi_matrix1', delta_f);
%% plot CSI phase with linear fit
figure('Name', 'CSI phase with linear fit');
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
%%*************************************************************************************************************
%% plot CSI phase with linear fit
subplot(223); plot(phase_matrix', ':');
grid on; hold on;
plot(phase_matrix1');
title('CSI phase with linear fit');
%% plot CSI phase diference with linear fit
pdifference1 = phase_matrix' - phase_matrix1';
subplot(224); plot(pdifference1);
grid on;
title('CSI phase diference with linear fit');
%____________________________________________________________
%% plot CSI phase with linear fit
figure('Name', 'demo');
mcsiphase = angle(mcsi_matrix'); % 30*3
subplot(211); plot(mcsiphase, ':');
grid on; hold on;
mcsiphase1 = angle(mcsi_matrix1');
plot(mcsiphase1);
title('CSI phase with linear fit');
%% plot CSI phase diference with linear fit
pdifference1 = mcsiphase - mcsiphase1;
subplot(212); plot(pdifference1);
grid on;
title('CSI phase diference with linear fit');
%%
%{
%% plot CSI phase with linear fit
mcsiphase = angle(mcsi_matrix'); % 30*3
subplot(223); plot(mcsiphase, ':');
grid on; hold on;
mcsiphase1 = angle(mcsi_matrix1');
plot(mcsiphase1);
title('CSI phase with linear transformation');
%% plot CSI phase diference with linear fit
pdifference1 = mcsiphase - mcsiphase1;
subplot(224); plot(pdifference1);
grid on;
title('CSI phase diference with linear fit');
%}

