%%
function sampled_csi = csi_sampling(csi_trace, n, alt_begin_index, alt_end_index)
    % Variable number of arguments handling
    if nargin < 3   %函数的一个参数， nargin是用来判断输入变量个数的函数
        begin_index = 1;
        end_index = length(csi_trace);
    elseif nargin < 4
        begin_index = alt_begin_index;
        end_index = length(csi_trace);
    elseif nargin == 4
        begin_index = alt_begin_index;
        end_index = alt_end_index;
    end
    
    % Sampling
    sampling_interval = floor((end_index - begin_index + 1) / n);
    sampled_csi = cell(n, 1);
    jj = 1;
    for ii = begin_index:sampling_interval:end_index   % 按 sampling_interval间隔进行采样
        % Get CSI for current packet
        sampled_csi{jj} = csi_trace{ii};  % csi_trace{ii}是取内容
        jj = jj + 1;
    end
end