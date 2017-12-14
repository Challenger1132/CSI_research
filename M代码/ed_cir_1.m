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
        agc = csi_entry.agc;
        %%
        csi = get_scaled_csi(csi_entry);
        csi = squeeze(csi(1, :, :)); % 3*30
        cir = abs(ifft(csi, [], 2)) - csi_entry.agc; % 按行进行ifft
        [e, ~] = sort(cir, 2, 'descend');
        mainComp(:, :, indPkg) = e(:, [1: numOfComp]); % 3*numOfComp 取出排序后前numOfComp个能量分量
        %% 相位拟合之后的csi数据
        [mcsi, ~] = spotfi_algorithm_1(csi); % 3*30
        filterCir = abs(ifft(mcsi, [], 2)) - csi_entry.agc;
        [me, i] = sort(filterCir, 2, 'descend');
        mainFilterComp(:, :, indPkg) = me(:, [1: numOfComp]); % 3*numOfComp 取出排序后前numOfComp个能量分量
        %%
        origCsi = csi_entry.csi;
        origCsi = squeeze(origCsi);  % 减去自动增益控制
        oriCir = abs(ifft(origCsi, [], 2)) - csi_entry.agc; % 按行进行ifft
        %%
        [oe, ~] = sort(oriCir, 2, 'descend');
        mainOrigComp(:, :, indPkg) = oe(:, [1: numOfComp]); % 3*numOfComp 取出排序后前numOfComp个能量分量
    end
    EnComp{indFile} = mainComp;
    EnFilterComp{indFile} = mainFilterComp;
    EnOrigComp{indFile} = mainOrigComp;
end
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
%{
将三天线之间数据做了个求和，瞬间变好了!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%}
PLOT_3_ANTENNA_SUM = 1;
if PLOT_3_ANTENNA_SUM
    xdata = [1:length(fileList)]*0.5 + 0.5;
    figure('Name', 'sumEnergy');
    d1 = sum(sumEnergy, 1);
    data1 = squeeze(d1);
    boxplot(data1, xdata); title('Distance Estimation with Scaled CSI'); grid on;

    figure('Name', 'sumFilterEnergy');
    d2 = sum(sumFilterEnergy, 1);
    data2 = squeeze(d2);
    boxplot(data2, xdata); title('Distance Estimation with Filter CSI'); grid on;

    figure('Name', 'sumOriEnergy');
    d3 = sum(sumOriEnergy, 1);
    data3= squeeze(d3);
    boxplot(data3, xdata); title('Distance Estimation'); grid on;
end




    
        