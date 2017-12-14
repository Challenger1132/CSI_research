%{
CSI --> CIR --->小于CIR峰值能量的0.3的滤除掉
在一定程度上滤除多径效应的干扰，
%}
function filter_csi = alleviateMultiPath(csi, alpha)
    if nargin < 2
        alpha = 0.3;
    end
    cir = ifft(csi, [], 2);     % size(csi) = 3 * 30
    absCir = abs(cir);
    maxCir = max(absCir, [], 2);
    f1 = absCir(1, :) >= maxCir(1)*alpha;
    f2 = absCir(2, :) >= maxCir(2)*alpha;
    f3 = absCir(3, :) >= maxCir(3)*alpha;
    cir(1, :) = cir(1, :).*f1;
    cir(2, :) = cir(2, :).*f2;
    cir(3, :) = cir(3, :).*f3;
    filter_csi = fft(cir, [], 2);
end
