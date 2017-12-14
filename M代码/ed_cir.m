%%
filePath = 'F:\netlink\training_distance\';
dirInfo = dir(fullfile(filePath, '*.dat'));
fileList = {dirInfo.name}.'; % fileList是一个cell数组
npkgs = 100;
EnComp = cell(length(fileList), 1);
EnFilterComp = cell(length(fileList), 1);
EnOrigComp = cell(length(fileList), 1);
numOfComp = 3;
%%
for indFile = 1:length(fileList)  % for 每一个 .dat 文件
    mainComp = zeros(3, numOfComp, npkgs); % 3 antennas * numOfComp * npkgs;
    mainFilterComp = zeros(3, numOfComp, npkgs);
    mainOrigComp = zeros(3, numOfComp, npkgs);
    csi_trace = read_bf_file([filePath, fileList{indFile}]);
    for indPkg = 1:npkgs % 对每一个csi_trace, 最后的到一个 3 * numOfComp * npkgs的矩阵
        csi_entry = csi_trace{indPkg};
        csi = get_scaled_csi(csi_entry);
        csi = squeeze(csi(1, :, :)); % 3*30
        cir = abs(ifft(csi, [], 2)); % 按行进行ifft
        [e, ~] = sort(cir, 2, 'descend');
        mainComp(:, :, indPkg) = e(:, [1: numOfComp]); % 3*numOfComp 取出排序后前numOfComp个能量分量
        %% 相位拟合之后的csi数据
        [mcsi, ~] = spotfi_algorithm_1(csi); % 3*30
        filterCir = abs(ifft(mcsi, [], 2));
        [me, i] = sort(filterCir, 2, 'descend');
        mainFilterComp(:, :, indPkg) = me(:, [1: numOfComp]); % 3*numOfComp 取出排序后前numOfComp个能量分量
        %%
        origCsi = csi_entry.csi;
        origCsi = squeeze(origCsi);
        oriCir = abs(ifft(origCsi, [], 2)); % 按行进行ifft
        [oe, ~] = sort(oriCir, 2, 'descend');
        mainOrigComp(:, :, indPkg) = oe(:, [1: numOfComp]); % 3*numOfComp 取出排序后前numOfComp个能量分量
    end
    EnComp{indFile} = mainComp;
    EnFilterComp{indFile} = mainFilterComp;
    EnOrigComp{indFile} = mainOrigComp;
end
%% 采用箱图绘制
%{
indComp = 1;
boxPlotData = zeros(npkgs, length(fileList), 3);  % 包数 * 文件数(距离) * 3天线
for indFile = 1:length(fileList)
    mainComp = EnFilterComp{indFile};
    tmpBoxData = squeeze(mainComp(:, indComp, :));
    boxPlotData(:, indFile, :) = tmpBoxData.';
end
indAnt = 1;
data = squeeze(boxPlotData(:, :, indAnt));
%%
xdata = [1:length(fileList)]*0.6;
boxplot(data, xdata); title('Distance Estimation'); grid on;
%}
%%
sumEnergy = zeros(3, npkgs, length(fileList));
sumFilterEnergy = zeros(3, npkgs, length(fileList));
sumOriEnergy = zeros(3, npkgs, length(fileList));
for indFile = 1:length(fileList)  % for 每一个 .dat 文件
    tmpEn = EnComp{indFile}; % 3 antennas * numOfComp * npkgs;
    tmp1 = squeeze(sum(tmpEn, 2));
    sumEnergy(:, :, indFile) = tmp1;
    %%
    filterTmpEn = EnFilterComp{indFile}; % 3 antennas * numOfComp * npkgs;
    tmp2 = squeeze(sum(filterTmpEn, 2));
    sumFilterEnergy(:, :, indFile) = tmp2;
    %%
    oriTmpEn = EnOrigComp{indFile}; % 3 antennas * numOfComp * npkgs;
    tmp3 = squeeze(sum(oriTmpEn, 2));
    sumOriEnergy(:, :, indFile) = tmp3;
end
%%
indAnt = 1;
xdata = [1:length(fileList)]*0.6;
data1 = squeeze(sumEnergy(indAnt, :, :));
data2 = squeeze(sumOriEnergy(indAnt, :, :));
subplot(211); boxplot(data1, xdata); title('Distance Estimation'); grid on;
subplot(212); boxplot(data2, xdata); title('Distance Estimation'); grid on;





    
        