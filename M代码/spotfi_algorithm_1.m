function [csi_matrix, phase_linear_fit] = spotfi_algorithm_1(csi_matrix, delta_f)
    %lgtm源码修改版，和lgtm源码功能一样
    % 3*30
    %{
    R = abs(csi_matrix); % 未经线性拟合的数据  3 * 30
    phase_matrix = unwrap(angle(csi_matrix), pi, 2);
    packet_one_phase_matrix = phase_matrix;
    % STO is the same across subcarriers....
    var = 1:30;
    fit_X = [var'; var'; var'];
    fit_Y = reshape(packet_one_phase_matrix', 90, 1);
    % Linear fit is common across all antennas
    result = polyfit(fit_X, fit_Y, 1);
    tau = result(1);
    for m = 1:size(phase_matrix, 1)
        for n = 1:size(phase_matrix, 2)
            % Subtract the phase added from sampling time offset (STO)
            phase_matrix(m, n) = packet_one_phase_matrix(m, n) + (2 * pi * delta_f * (n - 1) * tau);
            % phase_matrix(m, n) = packet_one_phase_matrix(m, n) - (n - 1) * tau;
        end
    end
    % Reconstruct the CSI matrix with the adjusted phase
    csi_matrix = R .* exp(1i * phase_matrix);
    %}
    R = abs(csi_matrix); % 未经线性拟合的数据  3 * 30
    phase = angle(csi_matrix);
    phase_matrix = unwrap(phase, pi, 2);
    % STO is the same across subcarriers....
    var = 1:30;
    fit_X = [var'; var'; var'];
    fit_Y = reshape(phase_matrix', 90, 1);
    % Linear fit is common across all antennas
    result = polyfit(fit_X, fit_Y, 1);
    tau = result(1);
    phase_linear_fit = zeros(3, 30);
    for m = 1:size(phase_matrix, 1)     % 3
        for n = 1:size(phase_matrix, 2)     % 30
            phase_linear_fit(m, n) = phase_matrix(m, n) + (2 * pi * delta_f * (n - 1) * tau);
            % phase_linear_fit(m, n) = phase_matrix(m, n) - (n - 1) * tau;
        end
    end
    % Reconstruct the CSI matrix with the adjusted phase
    csi_matrix = R .* exp(1i * phase_linear_fit);
end