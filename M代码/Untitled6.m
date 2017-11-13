xn = round(rand(1,10)*10);
xk = fft(xn);
xkmy = myfft(xn);
subplot(221);
stem(xk);
subplot(222);
stem(xkmy);
%%
subplot(223);
y = ifft(xn);
ymy = myifft(xn);
stem(y);
subplot(224);
stem(ymy);

