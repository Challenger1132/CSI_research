
function spotfi_file_runner(input_file_name)
    run(input_file_name);
end

function run(data_file)
    frequency = 5.745e9;
    sub_freq_delta = (4e7) / 30;
	c = 3*10^8;
	lambda = c / frequency;
	antenna_distance = 0.0261;
    csi_trace = read_bf_file(data_file);

    num_packets = length(csi_trace);
    fprintf('num_packets: %d\n', num_packets)
    sampled_csi_trace = csi_sampling(csi_trace, num_packets, ...
            1, length(csi_trace));
    spotfi(sampled_csi_trace, frequency, sub_freq_delta, antenna_distance);
end