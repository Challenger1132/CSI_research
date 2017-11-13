
%GET_TOTAL_RSS Calculates the Received Signal Strength (RSS) in dBm from
% a CSI struct.
%
% (c) 2011 Daniel Halperin <dhalperi@cs.washington.edu>
% 到底用了哪个天线 ？
function ret = get_total_rss(csi_st)
    error(nargchk(1,1,nargin));

    % Careful here: rssis could be zero
    rssi_mag = 0;
    if csi_st.rssi_a ~= 0   % A天线的信号强度
        rssi_mag = rssi_mag + dbinv(csi_st.rssi_a);
    end
    if csi_st.rssi_b ~= 0	% B天线的信号强度
        rssi_mag = rssi_mag + dbinv(csi_st.rssi_b);
    end
    if csi_st.rssi_c ~= 0	% C天线的信号强度
        rssi_mag = rssi_mag + dbinv(csi_st.rssi_c);
    end
    
    ret = db(rssi_mag, 'pow') - 44 - csi_st.agc;
end
% 得到三个天线的信号强度的和，返回的是 db形式

