%% read file
clc;clear all;
index = 5;
sub_freq_delta = (40 * 10^6) /30;  % 子载波间
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

%
figure(1);
origin_csi_phase = angle(csis{index});
subplot(321), plot(origin_csi_phase);
title('origin CSI phase');

unwrapd_csi = unwrap(angle(csis{index}), pi, 1);
subplot(322), plot(unwrapd_csi);
title('unwrapd CSI phase');
%% 
[sanitized_csi, phase_matrix] = spotfi_algorithm_1(csis{index}.', sub_freq_delta);
sanitized_csi_phase = angle(sanitized_csi'); % 30*3
sanitized_csi_phase = unwrap(sanitized_csi_phase, pi, 1);
subplot(323), plot(sanitized_csi_phase);
title('liner fit CSI phase 1');

[sanitized_csi, phase_matrix] = spotfi_algorithm_1(csis{index}.', sub_freq_delta);
phase_matrix = phase_matrix';
sanitized_csi_phase = unwrap(phase_matrix, pi, 1);
subplot(324), plot(sanitized_csi_phase);
title('liner fit CSI phase 2');


%{
%%
subplot(324), plot(db(abs(csis{index}))); % 30*3
legend('RX Antenna A', 'RX Antenna B', 'RX Antenna C', 'Location', 'SouthEast' );
xlabel('Subcarrier index');
ylabel('SNR [dB]');
title('CSI amplitude')
%%
cir_data = cirs{index};
subplot(325), bar(1:30, cir_data);
axis([1,30,0,35]);
set(gca, 'XTick', 1:30);
title('CIR ');
xlabel('Delay');
ylabel('Amplitude');
%}








