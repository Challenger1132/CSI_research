%% 采集数据
clear all;
clc;

csi_trace = read_bf_file('4.0-15r-5.dat');
num_package = length(csi_trace);
fprintf('mumber_package = %d\n', num_package);
csis = cell(num_package, 1);
%%
for ii = 1:num_package
    csi_entry = csi_trace{ii};
    temp = get_scaled_csi(csi_entry);
    temp = temp(1, :, :);
    temp = squeeze(temp);
    temp = temp([1 2 3], :);
    csis{ii} = temp;
end
index = 10;
csi_matrix = csis{index}; 
R = abs(csi_matrix); % 未经线性拟合的数据  3 * 30
phase_matrix = unwrap(angle(csi_matrix), pi, 2);
%% 
% 3天线联合拟合
x = 1:30; 
% x = 1:30; [-0.7562, -0.0557]          x = 0:29;  [-0.7561,-0.8119]
fit_X = [x'; x'; x'];
fit_Y = reshape(phase_matrix', 90, 1);
result1 = polyfit(fit_X, fit_Y, 1);
temp = polyval(result1, fit_X);
figure('Name', 'fit result');
plot(fit_Y); hold on;
plot(temp, 'r');

tau1 = result1(1);
y = 0:29;
result_phase = phase_matrix - [y; y; y]*tau1;
%%
% 单独进行拟合方式1
delta_f = 4*0.3125*10^6;
ant1 = phase_matrix(1, :); % 某个天线的数据
ant2 = phase_matrix(2, :);
ant3 = phase_matrix(3, :);
ptemp = 2*pi*delta_f;
x = ptemp*linspace(0, 29, 30);  % 构造的输入数据x 
y1 = polyfit(x, ant1, 1);
y2 = polyfit(x, ant2, 1);
y3 = polyfit(x, ant3, 1);
d1 = y1(1); % 三天线的数据分别拟合得到的斜率a
d2 = y2(1);
d3 = y3(1);
d = [d1; d2; d3];
p1 = ant1 + x*d1;
p2 = ant2 + x*d2;
p3 = ant3 + x*d3;
result_phase2 = [p1; p2; p3];
%%
%单独进行拟合 方式2
%{ 
x = 1:30
[-0.7654, 3.0824; 
 -0.7401, -2.2039;
 -0.7631, -1.0459]
x = 0:29
[ -0.7654,  2.317]
[ -0.7401, -2.944]
[ -0.7631, -1.809]
%}
data1 = phase_matrix(1, :); % 某个天线的数据
data2 = phase_matrix(2, :);
data3 = phase_matrix(3, :);
x = linspace(0, 29, 30);  % 构造的输入数据x 
y1 = polyfit(x, data1, 1);
y2 = polyfit(x, data2, 1);
y3 = polyfit(x, data3, 1);
dd1 = y1(1); % 三天线的数据分别拟合得到的斜率a
dd2 = y2(1);
dd3 = y3(1);
dd = [y1; y2; y3];
pp1 = data1 - (x-1)*dd1;
pp2 = data2 - (x-1)*dd2;
pp3 = data3 - (x-1)*dd3;
result_phase3 = [pp1; pp2; pp3];
%%
figure('Name', 'plot phase');
subplot(311); plot(result_phase.');
subplot(312); plot(result_phase2.');
subplot(313); plot(result_phase3.');
