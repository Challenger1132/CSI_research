%% subplot图像绘制出来和phase_analysis.m一样
clc;clear all;
csi_trace = read_bf_file('3.5-30-5.dat');
num_package = length(csi_trace);
csis = cell(num_package, 1);
%%
for ii = 1:num_package
    csi_entry = csi_trace{ii};
    temp = get_scaled_csi(csi_entry);
    temp = temp(1, :, :);
    csis{ii} = squeeze(temp).'; % 30*3
end
%%
figure('Name', 'CSI phase with linear transformation');
index = 10;
    csi = csis{index}; % 30*3
    [csi_matrix1, csi_phase1] = spotfi_algorithm_1(csi.'); % input 3*30 linear_transform
    [csi_matrix2, csi_phase2] = spotfi_algorithm_2(csi.'); % input 3*30 linear_transform
    %% plot CSI phase
    subplot(221); plot(angle(csi)); grid on;hold on; 
    subplot(222); plot(unwrap(angle(csi), pi, 1)); grid on;hold on; 
    mcsiphase1 = unwrap(angle(csi_matrix1.'), pi, 1);
    mcsiphase2 = unwrap(angle(csi_matrix2.'), pi, 1);
    subplot(223); plot(mcsiphase1); grid on;hold on;  title('algorithm 1');
    subplot(224); plot(mcsiphase2); grid on;hold on;  title('algorithm 2');