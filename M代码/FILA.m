clc;clear;close all;
% addpath(genpath('../linux-80211n-csitool-supplementary'));
% root = 'F:\定位\CSI\linux-80211n-csitool-supplementary-master\linux-80211n-csitool-supplementary-master\matlab\data';
root = 'data\';
file = fopen('demo.txt','r');
n=31;
L=1;
while ~feof(file)
        str = fgetl(file);
    if ~isempty(str)
        name{L,1}=str;
        L=L+1;
    end
end
fclose(file);
% 建立有效csi数组
x = 100;    
effcsitotal = zeros(30,x);
csi_sq_all = zeros(30,1000,30);
for a =2:31
    filename = char(name(a)); % 文件名
    filepath = [root,filename];
    csi_trace = read_bf_file(filepath);
    fc = 5.32*10^9;
    delt_f = 312.5*10^3;
    subCarrierIndex = [-28:2:28];
    K = 30;
    % 数据集制作
    % 选取x个随机struct
    % c=randperm(numel(csi_trace));
    % csi_trace1=csi_trace(c(1:x));
    csi_trace1 = csi_trace(1:x);
    for j =1:length(csi_trace1)
    % 数据预处理
    % step1: 滤波
        csi_entry = csi_trace{j};
        USE_CSI_EFF = false;
        if USE_CSI_EFF
            perm = csi_entry.perm;
            csi = csi_entry.csi;
%             csi = get_scaled_csi(csi_entry);
            [result, index]=sort(perm);
            csi_sq = squeeze(csi(1, index(1), :));
            csi_sq_all(a-1,j,:) = csi_sq';
    %         csi_sq = squeeze(csi(1,1,:));
            effcsi = 0;
            for i =1: length(subCarrierIndex)
                effcsi = effcsi + ((fc+subCarrierIndex(i)*delt_f)/fc)*abs(csi_sq(i));  
            end 
            effcsi = (1/K)*effcsi;
            effcsitotal((a-1),j)=effcsi;
        end
        
        USE_CSI_SCALE = true;
        if USE_CSI_SCALE
            perm=csi_entry.perm;
            % csi = csi_entry.csi;
            csi = get_scaled_csi(csi_entry);
            [result, index] = sort(perm);
            csi_sq = squeeze(csi(1,index(1),:));
            csi_sq_all(a-1, j, :) = csi_sq';
            effcsi = 0;
            for i =1: length(subCarrierIndex)
                effcsi = effcsi + ((fc + subCarrierIndex(i)*delt_f)/fc)*abs(csi_sq(i));  
            end 
            effcsi=(1/K)*effcsi;
%             effcsitotal((a-1),j) = abs(csi_sq(1));
            effcsitotal((a-1),j) = effcsi;
        end

        USE_RSS = false;
        if USE_RSS
            effcsitotal((a-1),j) = get_total_rss(csi_entry);
        end
    end
end
% 模型回归
%plot
boxplot(effcsitotal');

figure
histogram(effcsitotal(30,:)');

figure
boxplot(squeeze(abs(csi_sq_all(1,:,:))));

figure
boxplot(squeeze(abs(csi_sq_all(:,:,15)))');

% figure
% color = ['r','g','b'];
% start = 27;
% for i = start+1:start+3
%     for j = 1:100
%         plot(subCarrierIndex,db(abs(squeeze(csi_sq_all(i,j,:)))),color(i-start));
%         hold on;
%     end
% end
% 验证与测试