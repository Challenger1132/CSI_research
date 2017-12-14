clc;clear all;
csi_trace = read_bf_file('4.0-30-3.dat');
ind = 10;
csi_entry = csi_trace{ind};
csi = get_scaled_csi(csi_entry);
csi = squeeze(csi);
absCsi = abs(csi);

c1 = abs(ifft(csi, [], 2));
c2 = abs(ifft(absCsi, [], 2));
subplot(211); bar(c1.');
subplot(212); bar(c2.');