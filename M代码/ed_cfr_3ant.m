%{
分别求出3天线的CFR，绘制箱图
3天线的数据取平均，然后再绘制箱图
%}
filePath = 'F:\netlink\training_distance\';
dirInfo = dir(fullfile(filePath, '*.dat'));
fileList = {dirInfo.name}.'; % fileList是一个cell数组
npkgs = 100;
EnCfr = zeros(3, npkgs, length(fileList));
AGC = zeros(npkgs, length(fileList));
%%
for indFile = 1:length(fileList)  % for 每一个 .dat 文件
    mainComp = zeros(3, npkgs);
    csi_trace = read_bf_file([filePath, fileList{indFile}]);
    agc = zeros(npkgs, 1);
    for indPkg = 1:npkgs
        csi_entry = csi_trace{indPkg};
        %% AGC
        agc(indPkg) = csi_entry.agc;
        %% scaled csi
        csi = get_scaled_csi(csi_entry);
        csi = squeeze(csi(1, :, :)); % 3*30
        Ecsi = mean(abs(csi), 2);
        mainComp(:, indPkg) = Ecsi;
    end
    AGC(:, indFile) = agc;
    EnCfr(:, :, indFile) = mainComp;
end
%%
PLOT_CFR = 1;
xdata = [1:0.5:4.5];
if PLOT_CFR
    ant1 = db(squeeze(EnCfr(1, :, :)), 'pow') - AGC;
    ant2 = db(squeeze(EnCfr(2, :, :)), 'pow') - AGC;
    ant3 = db(squeeze(EnCfr(3, :, :)), 'pow') - AGC;
    figure('Name', 'ant 1', 'NumberTitle', 'off');
    boxplot(ant1, xdata); grid on; title('天线1 CFR');
    figure('Name', 'ant2', 'NumberTitle', 'off');
    boxplot(ant2, xdata); grid on; title('天线2 CFR');
    figure('Name', 'ant 3' , 'NumberTitle', 'off');
    boxplot(ant3, xdata); grid on; title('天线3 CFR');
end
ant = (ant1 + ant2 + ant3) / 3;
figure; boxplot(ant, xdata); grid on; title('3天线CFR的平均');







    
        