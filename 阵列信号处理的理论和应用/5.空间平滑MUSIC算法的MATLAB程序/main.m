%%% DOA estimation by  spatial smoothing or modified spatial smoothing
% Developed by xiaofei zhang (南京航空航天大学 电子工程系 张小飞）
% EMAIL:zhangxiaofei@nuaa.edu.cn
clear all;
close all;
SNR = 10;
derad = pi/180; % deg -> rad
radeg = 180/pi;
twpi = 2*pi;
Melm = 7; %阵元数
kelm = 6;  % 子阵阵元数
dd = 0.5; % 天线距离
d=0:dd:(Melm-1)*dd;
theta = [-50 0 30 45 60];
paths = length(theta); % 信源数 
samples = 100; % 快拍数
A=exp(-j*twpi*d.'*sin(theta*derad)); % 导向矩阵 7*3
coherentPath = 2;
S0=randn(paths-coherentPath, samples);
ComplexConst = randn+1j*randn;
S = [S0; ComplexConst*repmat(S0(1, :), coherentPath, 1)];  % 相干信号，复衰减系数
X0 = A*S;
X=awgn(X0, SNR, 'measured'); % 类似CSI，天线接收的数据
Rxxm=X*X'/samples; % 求协方差矩阵
issp = 2;
%%
% spatial smoothing music
if issp == 1
  Rxx = ssp(Rxxm, kelm); % 只有主对角线的子阵相加求和
elseif issp == 2
  Rxx = mssp(Rxxm, kelm); % 双向平滑方式
else
  Rxx = Rxxm;
  kelm = Melm;
end
% Rxx
[EV,D]=eig(Rxx);
EVA=diag(D)'; 
[EVA,I]=sort(EVA);
EVA
EVA=fliplr(EVA);
EV=fliplr(EV(:,I));

% 搜索
for iang = 1:361
        angle(iang) = (iang - 181) / 2;
        phim = derad*angle(iang);
        a = exp(-j*twpi*d(1:kelm)*sin(phim)).'; % 构建的导向矢量
        % 导向矢量要和阵列流型对齐，流型矩阵原来是M*paths的，因为进行了空间平滑(牺牲阵列孔径，导致协方差矩阵维度降低)
        % 所以现在导向矢量的维度不是M，而是size(d(1: kelm)), kelm是平滑后协方差矩阵的维度，也是子阵的阵元数
        L = paths; % 信源数
        En = EV(:, L+1:kelm); % 噪声子空间
        SP(iang) = (a'*a) / (a'*En*En'*a);
end
   
SP = abs(SP);
SPmax = max(SP);
SP=10*log10(SP/SPmax);
%SP=SP/SPmax;
figure(1);
h=plot(angle, SP);
set(h,'Linewidth',2)
xlabel('angle (degree)')
ylabel('magnitude (dB)')
axis([-90 90 -60 0])
set(gca, 'XTick',[-90:10:90], 'YTick',[-60:10:0])
grid on; hold on;
legend('平滑MUSIC');

 