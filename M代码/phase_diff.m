%% 相位差分析
clc;clear all;
csi_trace = read_bf_file('2.0-0-3.dat');
npkgs = length(csi_trace);
phase = zeros(3, 30, npkgs);
phaseUwrap = zeros(3, 30, npkgs);
for indPkg = 1:npkgs
    csi_entry = csi_trace{indPkg};
    csi = get_scaled_csi(csi_entry);
    csi = squeeze(csi(1, :, :)); % 3*30
    pha = angle(csi);
    phase(:, :, indPkg) = pha;
    phaseUwrap(:, :, indPkg) = unwrap(pha, pi, 2);
end
% for ind = 1: npkgs
%     phase = phaseUwrap(:, :, ind).';
%     plot(phase); hold on;
% end
phaseDiff = squeeze(phaseUwrap(1, :, :) - phaseUwrap(3, :, :)).';
subplot(221); boxplot(phaseDiff, [1:30]);
phaseDiff = squeeze(phaseUwrap(1, :, :) - phaseUwrap(3, :, :)).';
subplot(222);
for ind = 1:npkgs
    pd = phaseDiff(ind, :);
    scatter([1:30], pd);  hold on; grid on;
end
subplot(223); plot(phaseDiff.');





return;
PLOT_PHASE_1PKG = 0;
if PLOT_PHASE_1PKG
    ph = squeeze(phase(:, :, 1)); % pkg one
    phUnwrap = squeeze(phaseUwrap(:, :, 1));
    figure('Name', 'Phase diff');
    plot(ph.', 'Color', [.3 .4 .8]); hold on; grid on;
    plot(phUnwrap.', 'Color', [.6 .3 .4]);
end
%% 
%{
antenna#1 subc3
%}
PLOT_ORIG_PHASE = 0;
x = 1:npkgs;
if PLOT_ORIG_PHASE
    indAntenna = 1;
    indSubcarrier1 = 2;
    subc3 = squeeze(phase(indAntenna, indSubcarrier1, :));  % 
    indSubcarrier2 = 13;
    subc13 = squeeze(phase(indAntenna, indSubcarrier2, :));  %
    figure('Name', '2与13号子载波在NRX=1的相位差fig1', 'NumberTitle', 'off');
    subplot(221); scatter(x, subc3); grid on; title('subcarriers#3');
    subplot(222); scatter(x, subc13); grid on; title('subcarriers#13');
    subplot(223); scatter(x, subc3 - subc13); grid on; title('2与13号子载波在NRX=1的相位差');
    subplot(224); scatter(x, abs(subc3 - subc13)); grid on; title('2与13号子载波在NRX=1的相位差');
end
%%
PLOT_UNWRAP_PHASE = 0;
if PLOT_UNWRAP_PHASE
    indAntenna = 1;
    indSubcarrier1 = 2;
    subc3 = squeeze(phaseUwrap(indAntenna, indSubcarrier1, :));  % 
    indSubcarrier2 = 13;
    subc13 = squeeze(phaseUwrap(indAntenna, indSubcarrier2, :));  %
    figure('Name', '2与13号子载波在NRX=1的相位差fig2', 'NumberTitle', 'off');
    subplot(221); scatter(x, subc3); grid on; title('subcarriers#3');
    subplot(222); scatter(x, subc13); grid on; title('subcarriers#13');
    subplot(223); scatter(x, subc13 - subc3); grid on; title('2与13号子载波在NRX=1的相位差');
    subplot(224); scatter(x, abs(subc3 - subc13)); grid on; title('2与13号子载波在NRX=1的相位差');
end
%%
PLOT_DIFF_ANTENNA = 0;
if PLOT_DIFF_ANTENNA
    indsubcarrier = 5;
    indAnt1 = 1;
    indAnt2 = 3;
    ant1 = phase(indAnt1, indsubcarrier, :);
    ant2 = phase(indAnt2, indsubcarrier, :);
    figure('Name', '原始相位-同一个子载波在#1和#3天线上的相位差','NumberTitle', 'off');
    subplot(221); scatter(x, ant1); grid on; title('Antenna#1');
    subplot(222); scatter(x, ant2); grid on; title('Antenna#3');
    subplot(223); scatter(x, ant2 - ant1); grid on; title('同一个子载波在#1和#3天线上的相位差');
    subplot(224); scatter(x, abs(ant2 - ant1)); grid on; title('同一个子载波在#1和#3天线上的相位差');
end
%%
PLOT_DIFF_UNWRAP_ANTENNA = 0;
if PLOT_DIFF_UNWRAP_ANTENNA
    indsubcarrier = 2;
    indAnt1 = 1;
    indAnt2 = 2;
    ant1 = phaseUwrap(indAnt1, indsubcarrier, :);
    ant2 = phaseUwrap(indAnt2, indsubcarrier, :);
    figure('Name', 'Unwrap相位-同一个子载波在#1和#3天线上的相位差','NumberTitle', 'off');
    subplot(221); scatter(x, ant1); grid on; title('Antenna#1');
    subplot(222); scatter(x, ant2); grid on; title('Antenna#3');
    subplot(223); scatter(x, ant2 - ant1); grid on; title('同一个子载波在#1和#3天线上的相位差');
    subplot(224); scatter(x, abs(ant2 - ant1)); grid on; title('同一个子载波在#1和#3天线上的相位差');
end