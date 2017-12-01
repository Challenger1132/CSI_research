%% csi information
clc;clear all;
csi_trace = read_bf_file('2.0-0-3.dat');
npkgs = length(csi_trace);
pkg_ind = 10;
    csi_entry = csi_trace{pkg_ind};
    origin_csi = csi_entry.csi;
    origin_csi = squeeze(origin_csi(1, :, :)).';
    csi = get_scaled_csi(csi_entry);
    tmpcsi = csi;
    csi = squeeze(csi(1, :, :)).';
    subplot(221);   plot(db(abs(origin_csi))); grid on; hold on; title('original csi');
    subplot(222);   plot(db(abs(csi))); grid on; hold on; title('get scaled csi');
    legend('RX Antenna A', 'RX Antenna B', 'RX Antenna C', 'Location', 'SouthEast' );
