function cir_complex = get_cir_complex_via_ifft(csi_complex)
% csi_complex: (1, 3, 30)
% cir_complex: (3, 30)
    cir_complex = zeros(3, 30);
    
    tmp = csi_complex(1, 1, :);
    tmp = tmp(:);  %将矩阵变成列向量
    cir_complex(1,:) = ifft(tmp);
    
    tmp = csi_complex(1, 2, :);
    tmp = tmp(:);
    cir_complex(2,:) = ifft(tmp);
    
    tmp = csi_complex(1, 3, :);
    tmp = tmp(:);
    cir_complex(3,:) = ifft(tmp);
    
end
