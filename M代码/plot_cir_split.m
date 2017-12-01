%% get data from packages
clc;clear all;
sub_freq_delta = (40 * 10^6) /30;  % 子载波间隔
csi_trace = read_bf_file('dopler_lr_1ms_closer_6.dat');
num_package = length(csi_trace);
cirs = cell(num_package, 1);
csis = cell(num_package, 1);
%% get csi
for ind = 1:num_package
    csi_entry = csi_trace{ind};
    tempcir = get_scaled_csi(csi_entry);
    tempcir = tempcir(1, :, :); % extract only one antenna data
    csis{ind} = squeeze(tempcir).'; % 30*3
end
for ind = 1: num_package
    csi = csis{ind}; % 30 * 3
    cirs{ind} = abs(ifft(csi));  % 这个地方进行abs，逆变换的时候就无法进行
     %cirs{ind} = ifft(csi);
end

%% 获取多个数据包在每个子载波上的方差的图线
cirdata = zeros(30, 3, num_package); % 必须先构造数据块，否则无法求协方差
csidata = zeros(30, 3, num_package);
for ind = 1: num_package
    cir = cirs{ind}; % 30 * 3
    cirdata(:, :, ind) = cir;   % 将cir数据赋予cirdata的第ind层
    csi = csis{ind}; % 30 * 3
    csidata(:, :, ind) = csi;   % 将cir数据赋予cirdata的第ind层
end
cirvar = zeros(30, 3);
for i = 1:30
    for j = 1:3
        tmpcir = squeeze(cirdata(i, j, :));
        tempcir = tmpcir / max(tmpcir);
        cirvar(i, j) = var(tempcir);
        
    end
end
%%
figure('Name', 'Variance Of Specific Subcarrier');
subplot(211); bar(cirvar);