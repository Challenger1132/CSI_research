%% 线性拟合、直接补偿时间两种方式处理CSI 幅度 相位 CIR的比较
%% read file
clc;clear all;
sub_freq_delta = (40 * 10^6) /30;  % 子载波间隔
csi_trace = read_bf_file('3.5-30-5.dat');
num_package = length(csi_trace);
cirs = cell(num_package, 1);
csis = cell(num_package, 1);
filter_cirs = cell(num_package, 1);
mcsis = cell(num_package, 1);
compensate_csis = cell(num_package, 1);
%% get csi
for ind = 1:num_package
    csi_entry = csi_trace{ind};
    temp = get_scaled_csi(csi_entry);
    temp = temp(1, :, :); % extract only one antenna data
    csis{ind} = squeeze(temp).'; % 30*3
end
%% get cir
for ind = 1: num_package
    csi = csis{ind}; % 30 * 3
    cirs{ind} = abs(ifft(csi));  % 这个地方进行abs，逆变换的时候就无法进行
    % cirs{ind} = ifft(csi);
end
%% 得到线性拟合之后的CSI数据
for ind = 1: num_package
    origincsi = csis{ind};
    % [mcsi, ~] = linear_transform_qh(origincsi.'); % 3*30
    [mcsi, ~] = spotfi_algorithm_1(origincsi.'); % 3*30
    compensate_time = 1e-07;
    [mcsi1] = linear_compensate_200ns(origincsi.', compensate_time); % 3*30
    mcsis{ind} = mcsi;
    compensate_csis{ind} = mcsi1;
end
FILTER_CSI = 1;
PLOT_LINEARFIT_CSI = 1;
PLOT_COMPENSATE_PHASE = 1;
index = 10;

if PLOT_COMPENSATE_PHASE
    origincsi = csis{index}; % 30*3
    origincir = abs(ifft(origincsi));
    compensate_csi = compensate_csis{index}.'; % 30*3
    compensate_cir = abs(ifft(compensate_csi));
    origin_phase = unwrap(angle(origincsi), pi, 1);
    compensate_phase = unwrap(angle(compensate_csi), pi, 1);
    figure('Name', 'Compensate CSI phase'); grid on;    
    subplot(231); plot(db(abs(origincsi)));  title('original CSI Amplitude');
    subplot(234); plot(db(abs(compensate_csi)));  title('compensate CSI Amplitude');
    subplot(232); plot(origin_phase);   grid on;    title('original CSI phase');
    subplot(235); plot(compensate_phase);   grid on;   title('compensate CSI phase');
    subplot(233); bar(origincir);   grid on;    title('original CIR');
    subplot(236); bar(compensate_cir);   grid on;    title('compensate with 200ns CIR');
%     fprintf('energy of original CSI %f \n', sum(sum(origincir)));
%     fprintf('energy of compensated CSI %f \n', sum(sum(mcir)));
end
    
if PLOT_LINEARFIT_CSI
    origincsi = csis{index};
    origincir = abs(ifft(origincsi));
    mcsi = mcsis{index}.';
    mcir = abs(ifft(mcsi));
    figure('Name', 'CSI with linear fit');
    subplot(231); plot(db(abs(origincsi))); grid on;    title('origin CFR');
    subplot(234); plot(db(abs(mcsi)));  grid on;    title('linear fit CFR');% 要转置
    subplot(232); plot(unwrap(angle(origincsi), pi, 1));  grid on;    title('original CSI phase');% 要转置
    subplot(235); plot(unwrap(angle(mcsi), pi, 1));  grid on;    title('linear fit CSI phase');% 要转置
    subplot(233); bar(origincir);   grid on;    title('origin CIR');
    subplot(236); bar(mcir);    grid on;    title('linear fit CIR');
end


if FILTER_CSI
    csi = csis{index};
    cir = ifft(csi);
    abscirdata = abs(cir);
    max_cir = max(abscirdata, [], 1); % cir_data每一行的最大值
    cir_f = zeros(30, 3); % 30*3
    for i = 1 : size(cir, 2) % % 如果cir值小于峰值的0.5倍，则将对应的cir剔除掉
        for j = 1: size(cir, 1)
            if abscirdata(j, i) >= max_cir(i)*0.25
                cir_f(j, i) = cir(j, i);
            end
        end
    end
    csi_f = fft(cir_f);
    figure('Name', 'one package......');
    subplot(231); plot(db(abs(csi)));   grid on; title('original CSI Amplitude');
    subplot(233); bar(abs(cir));    grid on; title('original CIR');
    subplot(232); plot(unwrap(angle(csi), pi, 1));  grid on; title('original CSI phase');
    subplot(235); plot(unwrap(angle(csi_f), pi, 1));    grid on; title('filter CSI phase');
    subplot(234); plot(db(abs(csi_f)));     grid on; title('filter CSI Amplitude');
    subplot(236); bar(abs(cir_f));  grid on; title('filter CIR');
end








