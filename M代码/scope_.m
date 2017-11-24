%%
clc;clear all;
csi_trace1 = read_bf_file('3.0-30-3.dat');
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
    csis{ii} = temp.'; % 30*3
end
index = 10;
csi_matrix = csis{index}; % 30*3
csi_matrix1 = csis{index+1}; % 30*3
%% plot CSI phase
figure('Name', 'Unwrapped CSI phase with');
unwrapd_csi = unwrap(angle(csi_matrix), pi, 1);
plot(unwrapd_csi);
grid on; title('unwrapped CSI phase');
%% linear fit
dx = linspace(1, 30, 30)';
dy1 = unwrapd_csi(:, 1);
dy2 = unwrapd_csi(:, 2);
dy3 = unwrapd_csi(:, 3);
p1 = polyfit(dx, dy1, 1);
p2 = polyfit(dx, dy2, 1);
p3 = polyfit(dx, dy3, 1);
p = [p1; p2; p3];
% 拟合的数据
fy1 = polyval(p1, dx);
fy2 = polyval(p2, dx);
fy3 = polyval(p3, dx);
csi_matrix_fit = [fy1, fy2, fy3];
figure('Name', 'fit CSI phase');
plot(csi_matrix_fit);
grid on; title('fit CSI phase');
%%
%{
delta_f = 2*pi*t
t = d*sinθ / c
%}
delta_phi = p(1, 2) - p(3, 2);
delta_phi = delta_phi / pi;
delta_phi_mod = mod(delta_phi, pi);
theta = asin(delta_phi_mod / pi);
theta1 = rad2deg(theta);

