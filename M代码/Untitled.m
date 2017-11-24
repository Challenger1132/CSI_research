f1 = 20;
f2 = 20;
Fs = 8000; % 采样频率
N = 800; % 采样点
t = (0:N-1)/Fs;
phi1 = pi/4;
phi2 = pi;
s1 = sin(2*pi*f1*t + phi1);
s2 = sin(2*pi*f2*t + phi2);
s = s1 + s2;
figure('Name', 'time frequency analysis');
subplot(211);
plot(t, s1); hold on;
plot(t, s2);hold off;
grid on;
subplot(212);
plot(t, s);
grid on;
