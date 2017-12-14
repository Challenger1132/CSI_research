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
%%
filePath = 'F:\netlink\training_distance\';
dirInfo = dir(fullfile(filePath, '*.dat'));
fileList = {dirInfo.name}; % fileList是一个cell数组
npkgs = 100;
csieff_matrix = zeros(3, npkgs, length(fileList));
AGC = zeros(npkgs, length(fileList));
%%
for indFile = 1:length(fileList)
    csi_trace = read_bf_file([filePath, fileList{indFile}]);
    csieff_vec = zeros(3, npkgs);
    csiAgcs = zeros(npkgs, 1);
    for indPkg = 1:npkgs;
        csi_entry = csi_trace{indPkg};
        %% csi
        csi_matrix = get_scaled_csi(csi_entry);
        abs_csi = abs(squeeze(csi_matrix(1, :, :))); % 3*30
        csi_eff = sum(weight .* abs_csi, 2) / 30; % 3*1 按行求和
        csieff_vec(:, indPkg) = csi_eff;
       	%% AGC
        agc = csi_entry.agc;
        csiAgcs(indPkg) = agc;
    end
    csieff_matrix(:, :, indFile) = csieff_vec;
    AGC(:, indFile) = csiAgcs;
end
csieff_matrix = db(abs(csieff_matrix));
ant1 = squeeze(csieff_matrix(1, :, :)) - AGC;
ant2 = squeeze(csieff_matrix(2, :, :)) - AGC;
ant3 = squeeze(csieff_matrix(3, :, :)) - AGC;
meanAnt = (ant1 + ant2 + ant3) / 3;
meanAnt1 = (squeeze(csieff_matrix(1, :, :)) + squeeze(csieff_matrix(2, :, :)) + squeeze(csieff_matrix(3, :, :))) / 3 - AGC;
dis = 1:0.5:4.5;
figure; boxplot(ant1, dis); grid on; title('天线1');
figure; boxplot(ant2, dis); grid on; title('天线2');
figure; boxplot(ant3, dis); grid on; title('天线3');
figure; boxplot(meanAnt, dis); grid on; title('3天线平均');
figure; boxplot(meanAnt1, dis); grid on; title('3天线平均1');




