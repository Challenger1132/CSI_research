%{
原始CFR与scaled CFR以及滤除多径之后的CFR之间并没有太大的区别
一个pkg的数据分别求能量
%}
filePath = 'F:\netlink\training_distance\';
dirInfo = dir(fullfile(filePath, '*.dat'));
fileList = {dirInfo.name}.'; % fileList是一个cell数组
npkgs = 100;
EnComp = cell(length(fileList), 1);
EnOrigComp = cell(length(fileList), 1);
EnFilterComp = cell(length(fileList), 1);
AGC = zeros(npkgs, length(fileList));
%%
for indFile = 1:length(fileList)  % for 每一个 .dat 文件
    mainComp = zeros(3, 30, npkgs); % 3 antennas * 30 * npkgs;
    mainOrigComp = zeros(3, 30, npkgs);
    mainFilterComp = zeros(3, 30, npkgs);
    csi_trace = read_bf_file([filePath, fileList{indFile}]);
    agc = zeros(npkgs, 1);
    for indPkg = 1:npkgs % 对每一个csi_trace, 最后的到一个 3 * numOfComp * npkgs的矩阵
        csi_entry = csi_trace{indPkg};
        %% AGC
        agc(indPkg) = csi_entry.agc;
        %% scaled csi
        csi = get_scaled_csi(csi_entry);
        csi = squeeze(csi(1, :, :)); % 3*30
        mainComp(:, :, indPkg) = csi;
        %% 相位拟合之后的csi数据
        [mcsi] = alleviateMultiPath(csi, 0.25); % 3*30
        mainFilterComp(:, :, indPkg) = mcsi;
        %% original csi
        origCsi = csi_entry.csi;
        origCsi = squeeze(origCsi);
        mainOrigComp(:, :, indPkg) = origCsi;
    end
    AGC(:, indFile) = agc;
    EnComp{indFile} = mainComp;
    EnOrigComp{indFile} = mainOrigComp;
    EnFilterComp{indFile} = mainFilterComp;
end
%% 求csi幅值
cfrs = zeros(npkgs, length(fileList));
origCfrs = zeros(npkgs, length(fileList));
filterCfrs = zeros(npkgs, length(fileList));
for indFile = 1:length(fileList)
    csis = EnComp{indFile};
    cfr = zeros(npkgs, 1);
    origCsis = EnOrigComp{indFile};
    origCfr = zeros(npkgs, 1);
    filtercsi = EnFilterComp{indFile};
    filtercfr = zeros(npkgs, 1);
    for indPkg = 1: npkgs
        csi = csis(:, :, indPkg);
        csi_sq = csi.*conj(csi);
        csi_pwr = sum(csi_sq(:)) / 90;
        cfr(indPkg) = csi_pwr; %%
        %%
        origcsi = origCsis(:, :, indPkg);
        origcsi_sq = origcsi.*conj(origcsi);
        origcsi_pwr = sum(origcsi_sq(:)) / 90;
        origCfr(indPkg) = origcsi_pwr;
        %%
        fcsi = filtercsi(:, :, indPkg);
        fcsi_sq = fcsi.*conj(fcsi);
        fcsi_pwr = sum(fcsi_sq(:)) / 90;
        fCfr(indPkg) = fcsi_pwr;
    end
%     cfr = db(cfr, 'pow') - AGC(:, indFile);
    cfrs(:, indFile) = cfr;
    origCfrs(:, indFile) = origCfr;
    filterCfrs(:, indFile) = fCfr;
end
cfrs = db(cfrs, 'pow') - AGC;
origCfrs = db(origCfrs, 'pow') - AGC;
filterCfrs = db(filterCfrs, 'pow') - AGC;
%%
PLOT_SUM_CFR = 1;
xdata = [1:0.5:4.5];
if PLOT_SUM_CFR
    figure('Name', 'CSI幅值求和', 'NumberTitle', 'off');
    boxplot(cfrs, xdata); grid on; title('CSI幅值求和');
end
PLOT_SUM_ORIG_CFR = 1;
if PLOT_SUM_ORIG_CFR
    figure('Name', '原始CSI幅值求和', 'NumberTitle', 'off');
    boxplot(origCfrs, xdata); grid on; title('原始CSI幅值求和');
end
PLOT_FILTER_CFR = 1;
if PLOT_FILTER_CFR
    figure('Name', '平滑CSI幅值求和', 'NumberTitle', 'off');
    boxplot(filterCfrs, xdata); grid on; title('平滑CSI幅值求和');
end





    
        