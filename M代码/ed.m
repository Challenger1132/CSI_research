%{
对CSI数据进行IFFT变换，提取CIR数据，提取能量值最高的N个分量
然后进行距离估计
 %}
%% read file
clc;clear all;
fileName = '3.5-30-5.dat';
csi_trace = read_bf_file(fileName);
npkgs = length(csi_trace);
cirs = cell(npkgs, 1);
csis = cell(npkgs, 1);
filter_cirs = cell(npkgs, 1);
mcsis = cell(npkgs, 1);
%% get csi
for ind = 1:npkgs
    csi_entry = csi_trace{ind};
    temp = get_scaled_csi(csi_entry);
    temp = temp(1, :, :); % extract only one antenna data
    csis{ind} = squeeze(temp); % 3*30
end
%% get cir
for ind = 1: npkgs
    csi = csis{ind}; % 3 * 30
    cirs{ind} = abs(ifft(csi, [], 2));  % 这个地方进行abs，逆变换的时候就无法进行
    % cirs{ind} = ifft(csi);
end
%% 得到线性拟合之后的CSI数据
for ind = 1: npkgs
    origCsi = csis{ind};
    % [mcsi, ~] = linear_transform_qh(origincsi.'); % 3*30
    [mcsi, ~] = spotfi_algorithm_1(origCsi); % 3*30
    mcsis{ind} = mcsi;
    filterCir = abs(ifft(mcsi, [], 2));
    filter_cirs{ind} = filterCir;
end
%%
%{
PLOT_FIG = 1;
if PLOT_FIG
    figure('Name', 'cir csi');
    for ind = 1:npkgs
        csi = csis{ind};
        mcsi = mcsis{ind};
        subplot(221); plot(db(abs(csi.'))); hold on; grid on; title('original CSI');
        subplot(223); plot(db(abs(mcsi.'))); hold on; grid on; title('linear fit CSI');
    end
    index = 10;
    cir = cirs{index};
    filter_cir = filter_cirs{index};
    subplot(222); bar(cir.'); grid on; title('original CIR');
    subplot(224); bar(filter_cir.'); grid on; title('linear fit CIR');
end
%}
%%
%{
PLOT_AMPL_BAR = 0;
if PLOT_AMPL_BAR
    numOfComp = 3;
    cirAmpl = zeros(3, numOfComp, npkgs);
    filterCirAmpl = zeros(3, numOfComp, npkgs); 
    for ind = 1: npkgs
        tmp = sort(cirs{ind}, 2, 'descend');
        tmp1 = sort(filter_cirs{ind}, 2, 'descend');
        cirAmpl(:, :, ind) = tmp(:, [1: numOfComp]);
        filterCirAmpl(:, :, ind) = tmp1(:, [1: numOfComp]);
    end
    %%
    indComp = 1;
    energycir = mean(squeeze(cirAmpl(:, indComp, :)), 2); % 
    energyFiltercir = mean(squeeze(filterCirAmpl(:, indComp, :)), 2);
    %%
 	figure('Name', 'CIR ampl bar');
    subplot(311); 	bar(squeeze(cirAmpl(1, indComp, :)), 0.1, 'FaceColor',[0 .9 .5]); grid on; title('cirAmpl 1'); hold on; plot(ones(npkgs, 1)*energycir(1), 'r'); 
    subplot(312); 	bar(squeeze(cirAmpl(2, indComp, :)), 0.1, 'FaceColor',[0 .6 .5]); grid on; title('cirAmpl 2'); hold on; plot(ones(npkgs, 1)*energycir(2), 'r'); 
    subplot(313); 	bar(squeeze(cirAmpl(3, indComp, :)), 0.1, 'FaceColor',[0 .3 .5]); grid on; title('cirAmpl 3'); hold on; plot(ones(npkgs, 1)*energycir(3), 'r'); 
    figure('Name', 'CIR filter ampl bar'); 
    subplot(311); 	bar(squeeze(filterCirAmpl(1, indComp, :)), 0.1, 'FaceColor',[0 .9 .5]); grid on; title('cirAmpl 1'); hold on; plot(ones(npkgs, 1)*energyFiltercir(1), 'b'); 
    subplot(312); 	bar(squeeze(filterCirAmpl(2, indComp, :)), 0.1, 'FaceColor',[0 .6 .5]); grid on; title('cirAmpl 2'); hold on; plot(ones(npkgs, 1)*energyFiltercir(2), 'b'); 
    subplot(313); 	bar(squeeze(filterCirAmpl(3, indComp, :)), 0.1, 'FaceColor',[0 .3 .5]); grid on; title('cirAmpl 3'); hold on; plot(ones(npkgs, 1)*energyFiltercir(3), 'b'); 
end
%}
%% 提取能量最大的几个CIR数据分量
numOfComp = 3;
mainComp = zeros(3, numOfComp, npkgs); 
for ind = 1: npkgs
    cir = cirs{ind};
    [e, i] = sort(cir, 2, 'descend'); % 按行进行排序
    mcomp = e(:, [1: numOfComp]); % 3*numOfComp 取出排序后前numOfComp个能量分量
    mainComp(:, :, ind) = mcomp;
end
%%
figure('Name', 'Main component');
ant1 = squeeze(mainComp(1, :, :));
ant2 = squeeze(mainComp(2, :, :));
ant3 = squeeze(mainComp(3, :, :));
subplot(311); plot(ant1.');
subplot(312); plot(ant2.');
subplot(313); plot(ant3.');
%%
figure;
subplot(311); boxplot(ant1.');
subplot(312); boxplot(ant2.');
subplot(313); boxplot(ant3.');
%%




