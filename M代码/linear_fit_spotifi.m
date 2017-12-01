function [mcsi_matrix, mcsiphase] = linear_fit_spotifi(csi_matrix, delta_f)  %输入是3*30的CSI数据
% 根据spotifi提出的线性拟合算法来实现的
% 最小二乘法	“偏差的平方和最小的原则”
% 构造目标函数M，对目标函数对参数求偏导来求解拟合函数的各个参数
% MATLAB poltfit函数的也是根据最小二乘法的思想进行线性拟合的 (in a least-squares sense)
% faliure....
    R = abs(csi_matrix);
    csiphase = angle(csi_matrix);
    unwrap_csi = unwrap(csiphase, pi, 2);
    ant1 = unwrap_csi(1, :); % 某个天线的数据
    ant2 = unwrap_csi(2, :);
    ant3 = unwrap_csi(3, :);
    ptemp = 2*pi*delta_f;
    x1 = ptemp*linspace(0, 29, 30);  % 构造的输入数据x1、x2、x3
    x2 = ptemp*linspace(0, 29, 30);
    x3 = ptemp*linspace(0, 29, 30);
    y1 = polyfit(x1, ant1, 1);
    y2 = polyfit(x2, ant2, 1);
    y3 = polyfit(x3, ant3, 1);
    d1 = y1(1); %三天线的数据分别拟合得到的斜率a
    d2 = y2(1);
    d3 = y3(1);
    p1 = ant1 - x1*d1;
    p2 = ant2 - x2*d2;
    p3 = ant3 - x3*d3;
    mcsiphase = [p1; p2; p3];
    mcsi_matrix = R.*exp(1i*mcsiphase);
end
