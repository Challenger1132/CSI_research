%%
y = round(rand(1,10000)*100);
yMax=max(y);
yMin=min(y);
x=linspace(yMin,yMax,1000);
yy=hist(y,x);  % 统计点出现的个数
yy=yy / length(y); % 除以总数变为概率
subplot(221);
bar(x,yy);
subplot(222);
hist(y,x);
%%
meanval = 0;
var = 3;
cnt = 10000;
data = normrnd(meanval, var, [1, cnt]);
% data = rand(1,1000);
% data = round(data);
n = linspace(min(data), max(data), 10);
subplot(223);
hist(data,1000);
%%
meanval = 5;
var = 1;
cnt = 10000;
data = normrnd(meanval, var, [1, cnt]);
% data = round(data); % 取整消除了数据的多样性
n = linspace(min(data), max(data), 10000);
subplot(224);
hist(data,n);