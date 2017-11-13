function [mcsi_matrix, mcsiphase] = linear_transform(csi_matrix)  %输入是3*30的CSI数据
    R = abs(csi_matrix);
    csiphase = angle(csi_matrix);
    unwrap_csi = unwrap(csiphase, pi, 2);
    k = -58:4:58;
    ant1 = unwrap_csi(1, :);
    ant2 = unwrap_csi(2, :);
    ant3 = unwrap_csi(3, :);
    a1 = (ant1(30) - ant1(1)) / (58*2);
    b1 = mean(ant1);
    a2 = (ant2(30) - ant2(1)) / (58*2);
    b2 = mean(ant2);
    a3 = (ant3(30) - ant3(1)) / (58*2);
    b3 = mean(ant3);
    mant1 = ant1 - a1*k - b1;
    mant2 = ant2 - a2*k - b2;
    mant3 = ant3 - a3*k - b3;
    mcsiphase = [mant1; mant2; mant3];
    mcsi_matrix = R.*exp(1i*mcsiphase);
    %mcsi_matrix = R.*exp(-1i*mcsiphase); % 不一样
    
    %{
    figure('Name', 'phase phase'); %
    subplot(211); plot(mcsiphase'); % 相位矩阵mcsiphase直接绘制图像
    phase_again = angle(mcsi_matrix'); % 用相位矩阵mcsiphase构造CSI矩阵，然后再求相位矩阵phase_agein
    subplot(212); plot(phase_again);
    %}
end
