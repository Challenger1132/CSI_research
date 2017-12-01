%%
function [csi_matrix, phase_matrix] = spotfi_algorithm_2(csi_data, delta_f)
    R = abs(csi_data); % 未经线性拟合的数据  3 * 30
    origin_phase_matrix = unwrap(angle(csi_data), pi, 2);
    ant1 = origin_phase_matrix(1, :);
    ant2 = origin_phase_matrix(2, :);
    ant3 = origin_phase_matrix(3, :);
    x = 1:30;
    p1 = polyfit(x, ant1, 1);
    p2 = polyfit(x, ant2, 1);
    p3 = polyfit(x, ant3, 1);
    ant_fit1 = polyval(p1, x);
    ant_fit2 = polyval(p2, x);
    ant_fit3 = polyval(p3, x);
    result_phase1 = ant1 - ant_fit1;
    result_phase2 = ant2 - ant_fit2;
    result_phase3 = ant3 - ant_fit3;
    phase_matrix = [result_phase1; result_phase2; result_phase3];
    csi_matrix = R.*exp(1i*phase_matrix);
end