x = peaks(100);
SNR = 10;
y = awgn(x, SNR, 'measured');
figure(1);
subplot(221); mesh(x); hidden off;
subplot(222); mesh(y); hidden off;
subplot(223); surf(x); shading interp;
subplot(224); surf(y); sahding interp;