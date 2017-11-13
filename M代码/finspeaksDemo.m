x = linspace(1,10,50);
y = round(10*rand(1, length(x)));
y1 = sin(2*x).*(x - 4);
figure(1);
subplot(221);
[mv, mi]=findpeaks(y,'minpeakdistance',3);  %在3个元素中找到局部最大值
stem(x, y);hold on;
plot(x(mi), mv,'*','color','R');
subplot(222);
[mv, mi]=findpeaks(y,'minpeakdistance',6); %在6个元素中找到局部最大值
stem(x, y);hold on;
plot(x([mi]), mv,'*','color','R');

subplot(223);
[mv, mi]=findpeaks(y,'minpeakheight',8); % 峰值是必须大于8
stem(x, y);hold on;
plot(x([mi]), mv,'*','color','R');hold on;
plot(x, 8*ones(1, length(x)), 'r-.');
subplot(224);
[mv, mi]=findpeaks(y1);
stem(x, y1);hold on;
plot(x([mi]), mv,'*','color','R');
