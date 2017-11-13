% 实现对时域信号进行离散傅里叶变换
function [Xk, base] = demos(xn)
N = length(xn);
n = 0:N-1;
k = 0:N-1;
Wn = exp(-1i*2*pi/N);
base = n'*k; % N*N
Wnnk = Wn.^base;
qq = Wnnk
Xk = xn*Wnnk';
end
% 自定义的函数与自带函数不一样，复数中间的符号相反，但是模值相等,不论是fft 还是iffft