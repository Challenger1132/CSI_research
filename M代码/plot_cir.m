%% read file
clc;clear all;
sub_freq_delta = (40 * 10^6) /30;  % 子载波间隔
csi_trace = read_bf_file('3.5-30-5.dat');
num_package = length(csi_trace);
cirs = cell(num_package, 1);
csis = cell(num_package, 1);
filter_cirs = cell(num_package, 1);
filter_csis = cell(num_package, 1);
%% get csi
for ind = 1:num_package
    csi_entry = csi_trace{ind};
    temp = get_scaled_csi(csi_entry);
    temp = temp(1, :, :); % extract only one antenna data
    csis{ind} = squeeze(temp).'; % 30*3
end

%%
%{
对CSI数据进行ifft得到cir数据，滤除多径成分得到cir_f，进行fft，得到csi_f,
如果这个过程中滤除多径成分的阈值过大，导致某个天线的cir_f的数据为0，0+i*0,
那么绘制csi_f的图像时候，就会出现一条水平直线
%}
ONE_PACKAGE = 1;

if ONE_PACKAGE
    index = 10;
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
    subplot(221); plot(db(abs(csi)));
    subplot(222); bar(abs(cir));
    subplot(223); plot(db(abs(csi_f)));
    subplot(224); bar(abs(cir_f));
end
%% get cir

breakpoint = 0;



for ind = 1: num_package
    csi = csis{ind}; % 30 * 3
    % cirs{ind} = abs(ifft(csi));  % 这个地方进行abs，逆变换的时候就无法进行
    cirs{ind} = ifft(csi);
end
%% get filter cirs
tempval = 0.3;
for ind = 1:num_package
    cirdata = cirs{ind}; % 未进行abs
    abscirdata = abs(cirdata);
    max_cir = max(abscirdata, [], 1); % cir_data每一行的最大值
    cir_temp = zeros(30, 3); % 30*3
    for i = 1 : size(cirdata, 2) % % 如果cir值小于峰值的0.5倍，则将对应的cir剔除掉
        for j = 1: size(cirdata, 1)
            if abscirdata(j, i) >= max_cir(i)*tempval
                cir_temp(j, i) = cirdata(j, i);
            end
        end
    end
    filter_cirs{ind} = cir_temp; % 未进行abs
end
%% get filter csi
for ind = 1:num_package
    tmpcir = filter_cirs{ind}; % 未进行abs
    tmpcsi = fft(tmpcir, 30);
    filter_csis{ind} = tmpcsi;
end
%%
% configuration
PLOT_CIR = 1;
PLOT_CSI = 1;
PLOT_FILTER_CSI = 1;
CSI_FILTER = 0;
numpkg = 20;
%% 绘制CSI数据的幅度图像
if PLOT_CSI
    for ind = 1:numpkg
        csi_data = csis{ind};
        subplot(221),   plot(abs(csi_data)); % 30*3
        grid on; hold on;       title('ABS csi data');
        subplot(222),   plot(db(csi_data)); % 30*3
        grid on; hold on;       title('DB csi data');
        subplot(223);   plot(abs(db(csi_data)));
        grid on; hold on;       title('ABS & DB csi data');
        subplot(224);   plot(db(abs(csi_data)));
        grid on; hold on;       title('DB & ABS csi data');
    end
end
%%
index = 10;
cir_data = abs(cirs{index});
filter_cir_data = abs(filter_cirs{index});
if PLOT_CIR
    figure('Name', 'Power delay profile');
    subplot(211);   bar(1:30, cir_data);
    axis([1, 30, 0, 16]);
    grid on;    set(gca, 'XTick', 1:30);
    title('CIR ');      xlabel('Delay');    ylabel('Amplitude');
    subplot(212);   bar(1:30, filter_cir_data);
    axis([1, 30, 0, 16]);
    grid on;    set(gca, 'XTick', 1:30);
    title('CIR ');    xlabel('Delay');    ylabel('Amplitude');
end
%%
if PLOT_FILTER_CSI
    figure('Name', 'filter csi ampl');
    for ind = 1:numpkg
        csidata = csis{ind};
        csi_filter = filter_csis{ind};
        
        csidata = abs(csidata);
        csi_filter = abs(csi_filter);
        
        subplot(221);   plot(abs(csidata), ':');
        grid on;    hold on;
        plot(abs(csi_filter)); hold on;
        
        subplot(222);   plot(db(csidata), ':');
        grid on;    hold on;
        plot(db(csi_filter));
        grid on;    hold on;
        subplot(223);   plot(abs(db(csidata)), ':');
        grid on;    hold on;
        plot(db(abs(csi_filter)));
        grid on;    hold on;
         subplot(224);  plot(db(abs(csidata)), ':');
        grid on;    hold on;
        plot(db(abs(csi_filter)));
        grid on;    hold on;
    end
end
        

%% 利用频率多样性补偿小尺度衰落，利用OFDM多载波的机制，得到CSI_eff
if CSI_FILTER
    subcarriers_interval = 0.3125*10^6; % 312.5 khz
    cfreq = 5.745 * 10^9; % 中心频率
    tmp = cfreq - (15*4-2)*subcarriers_interval;
    subind = 0:29;
    subcarriers_freq = subind.'*subcarriers_interval*4 + tmp;
    csi_eff = zeros(3, 1);
    weight = subcarriers_freq / cfreq;
    csi_eff(:, 1) = sum(weight .* csi_data(:, 1)) / 30;
    csi_eff(:, 2) = sum(weight .* csi_data(:, 2)) / 30;
    csi_eff(:, 3) = sum(weight .* csi_data(:, 3)) / 30;
end
      








