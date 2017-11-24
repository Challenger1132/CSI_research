%%
function [csi_matrix, phase_matrix] = spotfi_algorithm_1(csi_matrix, delta_f)
    R = abs(csi_matrix); % 未经线性拟合的数据  3 * 30
    phase_matrix = unwrap(angle(csi_matrix), pi, 2);
    packet_one_phase_matrix = phase_matrix;
    fit_X(1:30, 1) = 1:1:30;
    fit_X(31:60, 1) = 1:1:30;
    fit_X(61:90, 1) = 1:1:30;
    fit_Y = zeros(90, 1);
    for i = 1:size(phase_matrix, 1) % 3
        for j = 1:size(phase_matrix, 2) % 30
            fit_Y((i - 1) * 30 + j) = packet_one_phase_matrix(i, j);
        end
    end
    result = polyfit(fit_X, fit_Y, 1);
    tau = result(1);

    for m = 1:size(phase_matrix, 1)
        for n = 1:size(phase_matrix, 2)
            % phase_matrix(m, n) = packet_one_phase_matrix(m, n) + (2 * pi * delta_f * (n - 1) * tau);
            phase_matrix(m, n) = packet_one_phase_matrix(m, n) - (n - 1) * tau;
        end
    end
    csi_matrix = R.*exp(1i * phase_matrix);
%% 精简改写版本
%     R = abs(csi_matrix); % 未经线性拟合的数据  3 * 30
%     phase_matrix = unwrap(angle(csi_matrix), pi, 2);
%     x = 1:30;
%     fit_X = [x'; x'; x'];
%     fit_Y = reshape(phase_matrix', 90, 1);
%     result = polyfit(fit_X, fit_Y, 1);
%     tau = result(1);
%     y = 0:29;
%     phase_matrix = phase_matrix - [y; y; y]*tau;
%     csi_matrix = R.*exp(-1i * phase_matrix);
end