%READ_BF_SOCKET Reads in a file of beamforming feedback logs.

function read_bf_socket_modify()

while 1
%% Build a TCP Server and wait for connection
% Using '0.0.0.0' as the IP address means that the server will accept the first
% machine that tries to connect. To restrict the connections that will be accepted,
% replace '0.0.0.0' with the address of the client in the code for Session 1.
    t = tcpip('0.0.0.0', 8090, 'NetworkRole', 'server');
    t.InputBufferSize = 1024;
    t.Timeout = 15;
    fopen(t); % 一旦fopen函数被调用，MATLAB进程就会被阻塞，直到收到连接或者 Ctrl+C强制结束

%% Set plot parameters
    clf;
    axis([1,30,-10,30]);
    t1 = 0;
    m1 = zeros(30,1);
	
	subplot(221); p_cfr = plot(t1,m1,'EraseMode','Xor','MarkerSize',5);
	xlabel('subcarrier index');
    ylabel('SNR (dB)');
	
	subplot(222); p_cir = plot(t1,m1,'EraseMode','Xor','MarkerSize',5);

    xlabel('subcarrier index');
    ylabel('CIR Amplitude (dB)');
	
	subplot(223); p_phase = plot(t1,m1,'EraseMode','Xor','MarkerSize',5);

    xlabel('subcarrier index');
    ylabel('Unwraped CIR Phase');
	
	subplot(224); p_linear_fit = plot(t1,m1,'EraseMode','Xor','MarkerSize',5);

    xlabel('subcarrier index');
    ylabel('Linear fit CIR Phase');	
	

%% Initialize variables
    ret = cell(1,1);
    index = -1;                     % The index of the plots which need shadowing
    broken_perm = 0;                % Flag marking whether we've encountered a broken CSI yet
    triangle = [1 3 6];             % What perm should sum to for 1,2,3 antennas

%% Process all entries in socket
    % Need 3 bytes -- 2 byte size field and 1 byte code
    while 1
        % Read size and code from the received packets
        s = warning('error', 'instrument:fread:unsuccessfulRead');
        try
            field_len = fread(t, 1, 'uint16');  % size
        catch
            warning(s);
            disp('Timeout, please restart the client and connect again.');
            break;
        end

        code = fread(t,1);    
        % If unhandled code, skip (seek over) the record and continue
        if (code == 187) % get beamforming or phy data
            bytes = fread(t, field_len-1, 'uint8');
            bytes = uint8(bytes);
            if (length(bytes) ~= field_len-1)
                fclose(t);
                return;
            end
        else if field_len <= t.InputBufferSize  % skip all other info
            fread(t, field_len-1, 'uint8');
            continue;
            else
                continue;
            end
        end

        if (code == 187) % (tips: 187 = hex2dec('bb')) Beamforming matrix -- output a record
            ret{1} = read_bfee(bytes);
        
            perm = ret{1}.perm;
            Nrx = ret{1}.Nrx;
            if Nrx == 1 % No permuting needed for only 1 antenna
                continue;
            end
            if sum(perm) ~= triangle(Nrx) % matrix does not contain default values
                if broken_perm == 0
                    broken_perm = 1;
                    fprintf('WARN ONCE: Found CSI (%s) with Nrx=%d and invalid perm=[%s]\n', filename, Nrx, int2str(perm));
                end
            else
                ret{1}.csi(:,perm(1:Nrx),:) = ret{1}.csi(:,1:Nrx,:);  % Nrx是收端天线数目
            end
        end
    
        index = mod(index+1, 10);
        % index取值是0-9
        csi = get_scaled_csi(ret{1});%CSI data
		csi = csi(1, :, :);  % 只取发端1天线
		csi = squeeze(csi).';  % 30*3
		cir = abs(ifft(csi));
		csi_phase = unwrap(angle(csi), pi, 1);
		linear_fit_phase = linear_fit(csi.');
	%You can use the CSI data here.

	%This plot will show graphics about recent 10 csi packets
	% plot CFR
        set(p_cfr(index*3 + 1),'XData', [1:30], 'YData', db(abs(csi(:, 1))), 'color', 'b', 'linestyle', '-');
        set(p_cfr(index*3 + 2),'XData', [1:30], 'YData', db(abs(csi(:, 2))), 'color', 'g', 'linestyle', '-');
        set(p_cfr(index*3 + 3),'XData', [1:30], 'YData', db(abs(csi(:, 3))), 'color', 'r', 'linestyle', '-');
	% plot CIR
		set(p_cir(index*3 + 1),'XData', [1:30], 'YData', cir(:, 1), 'color', 'b', 'linestyle', '-');
        set(p_cir(index*3 + 2),'XData', [1:30], 'YData', cir(:, 2), 'color', 'g', 'linestyle', '-');
        set(p_cir(index*3 + 3),'XData', [1:30], 'YData', cir(:, 3), 'color', 'r', 'linestyle', '-');
	% plot CSI phase
		
		set(p_phase(index*3 + 1),'XData', [1:30], 'YData', csi_phase(:, 1), 'color', 'b', 'linestyle', '-');
        set(p_phase(index*3 + 2),'XData', [1:30], 'YData', csi_phase(:, 2), 'color', 'g', 'linestyle', '-');
        set(p_phase(index*3 + 3),'XData', [1:30], 'YData', csi_phase(:, 3), 'color', 'r', 'linestyle', '-');
    % plot linear fit CSI phase
		
		set(p_linear_fit(index*3 + 1),'XData', [1:30], 'YData', linear_fit_phase(:, 1), 'color', 'b', 'linestyle', '-');
        set(p_linear_fit(index*3 + 2),'XData', [1:30], 'YData', linear_fit_phase(:, 2), 'color', 'g', 'linestyle', '-');
        set(p_linear_fit(index*3 + 3),'XData', [1:30], 'YData', linear_fit_phase(:, 3), 'color', 'r', 'linestyle', '-');    
		
		drawnow;
 
        ret{1} = [];
    end
%% Close file
    fclose(t);
    delete(t);
end

end