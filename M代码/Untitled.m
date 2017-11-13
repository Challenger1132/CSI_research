%% 读取数据
clc;clear all;
index = 15;
sub_freq_delta = (40 * 10^6) /30;
csi_trace = read_bf_file('csi_3.dat');
csi_entry = csi_trace{index};
csi = get_scaled_csi(csi_entry);
csi = squeeze(csi(1, :, :));
csi = csi.';  % 30*3
%% 原始相位
figure(1);
origin_csi_phase = angle(csi);
subplot(221), plot(origin_csi_phase); title('origin CSI phase');

%% unwrap相位
unwrapd_csi = unwrap(origin_csi_phase, pi, 1);
subplot(222), plot(unwrapd_csi); title('unwrapd CSI phase');

%% 线性拟合相位
[sanitized_csi, ~] = spotfi_algorithm_1(csi.', sub_freq_delta); % 3*30
sanitized_csi_phase = angle(sanitized_csi.'); % 30*3
sanitized_csi_phase = unwrap(sanitized_csi_phase, pi, 1);
subplot(223), plot(sanitized_csi_phase);
title('liner fit CSI phase 1');

% [~, phase_matrix] = spotfi_algorithm_1(csi.', sub_freq_delta); % 3*30
% phase_matrix = phase_matrix.';
% sanitized_csi_phase_1 = unwrap(phase_matrix, pi, 1);
% subplot(224), plot(sanitized_csi_phase_1);
% title('liner fit CSI phase 2');

%%
% linear_fit_csi_phase = linear_fit(csi.');
% subplot(224); plot(linear_fit_csi_phase);
% title('other deal phase');

%%
NT = numel(csi.');  % 90
M = size(csi.', 1);  % 3
N = size(csi.', 2);  % 30
col1 = ones(NT, 1);  % 90 * 1
col2 = repmat((0:1:(N-1))', M, 1);
A = [col1, col2]; % 90 * 2
b = reshape(csi.', numel(csi.'), 1); % 90 * 1
temp1 = A'*A;
temp2 = A'*b;
X = linsolve(A'*A, A'*b);
% beta = X(1);
rho = X(2);
rs_col2 = reshape(col2, 30, 3);
phase_matrix = csi.' - rs_col2'*rho;
R = abs(csi.');
csi_matrix = R .* exp(1i * phase_matrix);
subplot(224); plot(unwrap(angle(csi_matrix).'));
title('other deal phase');


% figure(2);
% subplot(311); plot(sanitized_csi_phase);
% subplot(312); plot(sanitized_csi_phase_1);
% data  = sanitized_csi_phase - sanitized_csi_phase_1;
% subplot(313); plot(data);






