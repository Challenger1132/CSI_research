function cir = get_cir_pic_from_csitrace(csi_trace, name)
    %csi_array=read_bf_file(fpath);
    %csi_trace = get_csi_trace_sqeezed(csi_trace);
 [size_1,~]=size(csi_trace);
    cir={};
    for ii=1:1:size_1
        csi_st = csi_trace{ii};
        csi_cpl = csi_st.csi;   %csi_st是结构体，通过csi_st.csi得到结构体中的数据
        %csi_cpl = get_scaled_csi(csi_st);
        cir_1 = get_cir_abs_via_ifft(csi_cpl); %返回3*30的矩阵
        bar(1:30, cir_1'); hold on;
        cir = [cir, cir_1];
    end
    axis([1,30,0,35]);
    set(gca, 'XTick', 1:30);
    title(name);
    xlabel('\bfDelay');
    ylabel('\bfAmplitude');
end
