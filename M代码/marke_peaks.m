%% 
% 找出3-D图像的包络，在峰值处添加一个标记
z = peaks;
v = linspace(-3,3,49);
[x,y] = meshgrid(v, v);
aoa_e = zeros(49, 1);
tof_e = zeros(49, 1);
for ii = 1 : size(z, 1)
    aoa_e(ii) = max(z(ii, :));
    tof_e(ii) = max(z(:, ii));
end
f = figure(1);
mesh(x,y,z');hold on;

figure(2);
subplot(211); plot(v, aoa_e);
subplot(212); plot(v, tof_e);

[~, aoa_lct] = findpeaks(aoa_e,'SortStr', 'descend');
aoa_lct_index = aoa_lct(1);  % 最大峰值对应的index
[~, tof_lct] = findpeaks(tof_e, 'SortStr', 'descend');
tof_lct_index = tof_lct(1);



x_aoa = v(aoa_lct_index);
y_tof = v(tof_lct_index);
z_db = z(aoa_lct_index, tof_lct_index);
ax = get(f, 'CurrentAxes');
scatter3(ax, x_aoa, y_tof, z_db, 'filled', 'MarkerEdgeColor','r'); hold on;
text(ax, x_aoa, y_tof, z_db, 'hello');