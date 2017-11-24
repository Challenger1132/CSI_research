%% configuration 
clc;clear all;
subcarriers_interval = 0.3125*10^6; % 312.5 khz
cfreq = 5.745 * 10^9; % 中心频率
tmp = cfreq - (15*4-2)*subcarriers_interval;
subind = 0:29;
subcarriers_freq = subind*subcarriers_interval*4 + tmp;
csi_eff = zeros(3, 1);
tmpweight = subcarriers_freq / cfreq;
weight = [tmpweight; tmpweight; tmpweight];

filePath = 'F:\netlink\training_distance\';
dirInfo = dir(fullfile(filePath, '*.dat'));
fileList = {dirInfo.name}; % fileList是一个cell数组
number_package = 100;
csieff_matrix = zeros(number_package, length(fileList), 3);
for ind = 1:length(fileList)
    csi_trace = read_bf_file([filePath, fileList{ind}]);    % for every .dat file
    csieff_vec = zeros(3, number_package); % 每一列是一个package的CSIeff, 共number_package个package
    for ii = 1:number_package; % for every package
        csi_entry = csi_trace{ii};
        csi_matrix = get_scaled_csi(csi_entry);
        csi_data = squeeze(csi_matrix(1, :, :)); % 3*30
        abs_csi = abs(csi_data);
        csi_eff = sum(weight .* abs_csi, 2) / 30; % 3*1 按行求和
        csieff_vec(:, ii) = csi_eff;
    end
    csieff_matrix(:, ind, :) = csieff_vec.';
end
csieff_matrix = db(abs(csieff_matrix));
antenna1 = squeeze(csieff_matrix(:, :, 1));
antenna2 = squeeze(csieff_matrix(:, :, 2));
antenna3 = squeeze(csieff_matrix(:, :, 3));
dis = 1:0.5:4.5;
plot(dis', antenna1.');





