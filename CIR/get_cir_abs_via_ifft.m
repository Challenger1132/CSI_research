function cir_abs = get_cir_abs_via_ifft(csi_complex)
% csi_complex: (1, 3, 30)
% cir: (3, 30)
    cir_abs = abs(get_cir_complex_via_ifft(csi_complex));
end