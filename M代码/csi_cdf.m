%% 可用于描述CSI数据稳定性
clc;clear all;
fileName = '2.0-0-3.dat';
csi_trace = read_bf_file(fileName);
npkgs = length(csi_trace);
csiData = zeros(3, 30, npkgs);
for indPkg = 1:npkgs
    csi_entry = csi_trace{indPkg};
    csi = get_scaled_csi(csi_entry);
    csi = squeeze(csi(1, :, :)); % 3*30
    csiData(:, :, indPkg) = csi;
end
%% 对每个包的30个子载波求std
for i = 1:3
    data = csiData(i, :, :);
    X = squeeze(data).'; % npkgs*30
	X = mapminmax(X, 0, 1);
    st = std(X, [], 1); % 对每一行的数据求std
    x(i, :) = st;
end
%%  对每个子载波的不同包求std
for i = 1:3
    data = csiData(i, :, :);
    X = squeeze(data); % 30*npkgs
	X = mapminmax(X, 0, 1);
    st = std(X, [], 2); % 对每一行的数据求std
    y(i, :) = st;
end
%% plot CDF graph
figure('Name', '对每个包的30个子载波求std');
h1 = cdfplot(x(1,:)); hold on;
h2 = cdfplot(x(2,:)); hold on;
h3 = cdfplot(x(3,:));
set(h1, 'Color', [.8, .2, .2]); set(h2, 'Color', [.2, .9, .2]); set(h3, 'Color', [.2, .2, .8]);
legend('RX Antenna A', 'RX Antenna B', 'RX Antenna C'); xlabel('std amplitude of csi'); ylabel('PDF');
%%
figure('Name', '对每个子载波的不同包求std');
h11 = cdfplot(y(1,:)); hold on;
h22 = cdfplot(y(2,:)); hold on;
h33 = cdfplot(y(3,:));
set(h11, 'Color', [.8, .2, .2]); set(h22, 'Color', [.2, .9, .2]); set(h33, 'Color', [.2, .2, .8]);
legend('RX Antenna A', 'RX Antenna B', 'RX Antenna C'); xlabel('std amplitude of csi'); ylabel('PDF');