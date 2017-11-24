clc;clear all;
csi_trace1 = read_bf_file('1-0-4.dat');
csi_trace2 = read_bf_file('4.5-60-5.dat');
num_package = 100;
csis1 = cell(num_package, 1);
csis2 = cell(num_package, 1);
%%
for ii = 1:num_package
    csi_entry1 = csi_trace1{ii};
    csi_entry2 = csi_trace2{ii};
    temp1 = get_scaled_csi(csi_entry1);
    temp2 = get_scaled_csi(csi_entry2);
    temp1 = squeeze(temp1(1, :, :));
    temp2 = squeeze(temp2(1, :, :));
    csis1{ii} = temp1.'; % 30*3
    csis2{ii} = temp2.'; % 30*3
end
for ii = 1: 30
    csi1 = csis1{ii};
    csi2 = csis2{ii};
    csi1 = csi1(:, 2);
    csi2 = csi2(:, 2);
    plot(db(abs(csi1(:, 2))), 'r'); hold on;
    plot(db(abs(csi2(:, 2))), 'b'); hold on;
end