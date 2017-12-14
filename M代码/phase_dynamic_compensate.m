%{
动态显示时间补偿过程中,从0ns 到100ns, CSI数据相位的变化
%}
%%
clc;clear all;
sub_freq_delta = 0.3125*10^6;  % 子载波间隔
csi_trace = read_bf_file('4.0-30-3.dat');
num_package = length(csi_trace);
csis = cell(num_package, 1);
%% get csi
for ind = 1:num_package
    csi_entry = csi_trace{ind};
    temp = get_scaled_csi(csi_entry);
    temp = temp(1, :, :); % extract only one antenna data
    csis{ind} = squeeze(temp).'; % 30*3
end
%% 
index = 10;
csi = csis{index};
compensate_time = (0: 1 :100)*1e-9;
phase_m = zeros(30, length(compensate_time));

tmpdata = zeros(length(compensate_time), 1);
for ind = 1:length(compensate_time)
    t = compensate_time(ind);
    [mcsi_matrix, phase_matrix] = linear_compensate_t(csi.', t);
    phase = unwrap(phase_matrix(1, :), pi, 2);
    plot(phase.'); grid on; hold on;
    pause(0.1);
    drawnow;
    phase_m(:, ind) = phase.';
    tmpdata(ind) = phase(1,1);
end
figure('Name', 'CSI phase');
plot(tmpdata);grid on;