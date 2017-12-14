%%
clc;clear all;
csi_trace = read_bf_file('2.0-0-3.dat');
npkgs = length(csi_trace);
csis = cell(npkgs, 1);
origCsis = cell(npkgs, 1);
csiAgc = zeros(npkgs, 1);
rssiAbc = zeros(npkgs, 3);
rssiTotal = zeros(npkgs, 1);
%%
for ind = 1:npkgs
    csi_entry = csi_trace{ind};
    %% orignal CSI 
    origCsi = squeeze(csi_entry.csi);
    origCsis{ind} = origCsi;
    %% AGC
    csiAgc(ind) = csi_entry.agc;
    %% Rssi a b c
    rssia = csi_entry.rssi_a;
    rssib = csi_entry.rssi_b;
    rssic = csi_entry.rssi_c;
    rssiAbc(ind, :) = [rssia, rssib, rssic];
    %% Rssi Total
    rssiTotal(ind) = get_total_rss(csi_entry);
    %% csi
    csi = get_scaled_csi(csi_entry);
    csis{ind} = squeeze(csi(1, :, :)); % 3*30
end
%%
PLOT_FIG = 0;
if PLOT_FIG
    figure('Name', 'csi info');
    subplot(221); plot(rssiTotal); grid on; title('Rssi Total ');
    subplot(222); plot(rssiAbc); grid on; title('Rssi A B C');
    subplot(223); plot(csiAgc); grid on; title('CSI Agc');
    subplot(224); plot(csiAgc); grid on; title('CSI Agc');
end
%%
PLOT_AMPL = 1;
if PLOT_AMPL 
    ind = 10;
    figure('Name', 'CSI ampl');
    csi = csis{ind};
    origCsi = origCsis{ind};
    plot(db(abs(csi.')), 'b'); grid on; hold on;
    plot(db(abs(origCsi.')), 'r'); grid on; hold on;
end
%%
