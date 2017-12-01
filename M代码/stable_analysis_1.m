%{
原始包CIR幅度，峰值有变动，应该是很不稳定的，
经过线性拟合处理之后幅度变得很稳定了
%}

%%
clc; clear all;
delta_f = (40 * 10^6) /30;  % 子载波间隔
csi_trace = read_bf_file('dopler_lr_10ms_closer2.dat');
npkg = length(csi_trace);
csis = cell(npkg, 1);
cirs = cell(npkg, 1);
cirs_qh = cell(npkg, 1);
cirs_spotfi = cell(npkg, 1);
cirs_algo1 = cell(npkg, 1);
cirs_algo2 = cell(npkg, 1);
csis_qh = cell(npkg, 1);
csis_spotfi = cell(npkg, 1);
csis_algo1 = cell(npkg, 1);
csis_algo2 = cell(npkg, 1);
%% get csi
for ind = 1:npkg
    csi_entry = csi_trace{ind};
    tempcir = get_scaled_csi(csi_entry);
    tempcir = tempcir(1, :, :); % extract only one antenna data
    csis{ind} = squeeze(tempcir).'; % 30*3
end
for ind = 1: npkg
    csi = csis{ind};	% 30 * 3
    cirs{ind} = abs(ifft(csi));  % 这个地方进行abs，逆变换的时候就无法进行
     %cirs{ind} = ifft(csi);
end
%%
for ind = 1:npkg
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
%%
ampl = zeros(npkg, 1);
ampl_qh = zeros(npkg, 1);
ampl_spotfi = zeros(npkg, 1);
ampl_algo1 = zeros(npkg, 1);
ampl_algo2 = zeros(npkg, 1);
antenna = 3;
for i = 1:npkg
    ampl(i) = max(cirs{i}(:, antenna));
    ampl_qh(i) = max(cirs_qh{i}(:, antenna));
    ampl_spotfi(i) = max(cirs_spotfi{i}(:, antenna));
    ampl_algo1(i) = max(cirs_algo1{i}(:, antenna));
    ampl_algo2(i) = max(cirs_algo2{i}(:, antenna));
end
% ampl_rand = ampl(randperm(length(ampl))); % 将数据变得很随机
figure('Name', 'CIR ampl');
subplot(321); 	bar(ampl, 0.1, 'FaceColor',[.42 .55 .13]); grid on; hold on; title('origin cir');
subplot(322); 	bar(ampl_qh, 0.1, 'FaceColor',[0 .5 .5]); grid on; title('qh cir');
subplot(323); 	bar(ampl_spotfi, 0.1, 'FaceColor',[.42 .55 .13]); grid on; hold on; title('spotfi cir');
subplot(324); 	bar(ampl_algo1, 0.1, 'FaceColor',[0 .5 .5]); grid on; title('algo1 cir');
subplot(325); 	bar(ampl_algo2, 0.1, 'FaceColor',[.42 .55 .13]); grid on; hold on; title('algo2 cir');
subplot(326); 	bar(ampl, 0.1, 'FaceColor',[0 .5 .5]); grid on; title('filter qh cir');
%%
var_origin = var(ampl);
var_qh = var(ampl_qh);
var_spotfi = var(ampl_spotfi);
var_algo1 = var(ampl_algo1);
var_algo2 = var(ampl_algo2);
%%
cirampl = zeros(30, 5);
ciramplqh = zeros(30, 5);
for ind = 1:5
    cir = cirs{ind}(:, 1);
    cirampl(:, ind) = cir;
    cir_qh = cirs_qh{ind}(:, 1);
    ciramplqh(:, ind) = cir_qh;
end
figure('Name', 'CIR ampl for 30 subcarriers');
subplot(211); bar(cirampl); grid on; title('original cir ');
subplot(212); bar(ciramplqh); grid on; title('original cir qh');
%%
