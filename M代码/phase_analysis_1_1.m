%% subplot图像绘制出来和phase_analysis.m一样
clc;clear all;
csi_trace = read_bf_file('3.5-30-5.dat');
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
index = 15;
csi_matrix = csis{index}; % 30*3
[mcsi_matrix, mcsiphase00] = spotfi_algorithm_1(csi_matrix', 0); % input 3*30  
[new_csi, mcsiphase000] = spotfi_algorithm_2(csi_matrix'); % input 3*30  
%% plot CSI phase
figure('Name', 'CSI phase with linear transformation');
subplot(221); plot(angle(csi_matrix)); grid on; title('original CSI phase');
subplot(222); plot(unwrap(angle(csi_matrix), pi, 1)); grid on;  title('unwrap CSI phase');
mcsiphase = angle(mcsi_matrix');
subplot(223); plot(mcsiphase); grid on; title('linear fit algorithm 1');
new_phase = angle(new_csi');
subplot(224); plot(new_phase); grid on; title('linear fit algorithm 2');