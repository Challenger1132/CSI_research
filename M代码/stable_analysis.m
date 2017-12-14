%{
分析几种线性拟合方式下
相位与CIR的情况
%}
clc; clear all;
delta_f = (40 * 10^6) /30;  % 子载波间隔
csi_trace = read_bf_file('3.5-30-5.dat');
num_package = length(csi_trace);
csis = cell(num_package, 1);
cirs = cell(num_package, 1);
cirs_qh = cell(num_package, 1);
cirs_spotfi = cell(num_package, 1);
cirs_algo1 = cell(num_package, 1);
cirs_algo2 = cell(num_package, 1);
csis_qh = cell(num_package, 1);
csis_spotfi = cell(num_package, 1);
csis_algo1 = cell(num_package, 1);
csis_algo2 = cell(num_package, 1);
%% get csi
for ind = 1:num_package
    csi_entry = csi_trace{ind};
    tempcir = get_scaled_csi(csi_entry);
    tempcir = tempcir(1, :, :); % extract only one antenna data
    csis{ind} = squeeze(tempcir).'; % 30*3
end
for ind = 1: num_package
    csi = csis{ind};	% 30 * 3
    cirs{ind} = abs(ifft(csi));  % 这个地方进行abs，逆变换的时候就无法进行
     %cirs{ind} = ifft(csi);
end

for ind = 1:num_package
    csi = csis{ind};
    [csi_spotfi, ~] = linear_fit_spotifi(csi.', delta_f); % 3*30
    [csi_qh, ~] = linear_transform_qh(csi.'); % 3*30
    [csi_algo1, ~] = spotfi_algorithm_1(csi.', delta_f); % 3*30
    [csi_algo2, ~] = spotfi_algorithm_2(csi.', delta_f); % 3*30
    %%
    csis_spotfi{ind} = csi_spotfi.';
    csis_qh{ind} = csi_qh.';
    csis_algo1{ind} = csi_algo1.';
    csis_algo2{ind} = csi_algo2.';
    %%
    cir_spotfi = abs(ifft(csi_spotfi.'));
    cir_qh = abs(ifft(csi_qh.'));
    cir_algo1 = abs(ifft(csi_algo1.'));
    cir_algo2 = abs(ifft(csi_algo2.'));
    %%
    cirs_qh{ind} = cir_spotfi;
    cirs_spotfi{ind} = cir_qh;
    cirs_algo1{ind} = cir_algo1;
    cirs_algo2{ind} = cir_algo2;
end
PLOT_PHASE = 1;
PLOT_CIR = 1;
index = 15;
if PLOT_PHASE
    csi = csis{index};
    csi_qh = csis_qh{index};
    csi_spotfi = csis_spotfi{index};
    csi_algo1 = csis_algo1{index};
    csi_algo2 = csis_algo2{index};
    figure('Name', 'plot phase');
    subplot(231); plot(unwrap(angle(csi), pi, 1)); grid on; title('origin CSI phase');
    subplot(232); plot(angle(csi_qh)); grid on; title('csi qh CSI phase');
    subplot(233); plot(angle(csi_spotfi)); grid on; title('csi spotfi CSI phase');
    subplot(234); plot(angle(csi_algo1)); grid on; title('csi algo1 CSI phase');
    subplot(235); plot(angle(csi_algo2)); grid on; title('csi algo2 CSI phase');
    subplot(236); plot(angle(csi)); grid on; title('origin CSI phase');
end
%%
if PLOT_CIR
    cir = cirs{index};
    cir_qh = cirs_qh{index};
    cir_spotfi = cirs_spotfi{index};
    cir_algo1 = cirs_algo1{index};
    cir_algo2 = cirs_algo2{index};
    figure('Name', 'plot cir');
    subplot(231); bar(cir); grid on; title('origin cir');
    subplot(232); bar(cir_qh); grid on; title('cir qh cir');
    subplot(233); bar(cir_spotfi); grid on; title('cirspotfi cir');
    subplot(234); bar(cir_algo1); grid on; title('cir algo1 cir');
    subplot(235); bar(cir_algo2); grid on; title('cir algo2 cir');
    subplot(236); bar(cir); grid on; title('origin cir');
end
%%









