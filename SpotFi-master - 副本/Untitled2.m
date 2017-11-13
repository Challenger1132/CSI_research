xxx = zeros(size(smoothed_sanitized_csis,1), 1);
for i = 1 : size(smoothed_sanitized_csis,1)
    x1 = smoothed_sanitized_csis{i};
    x2 = smoothed_sanitized_csis_m{i};
    temp = x1 ~= x2;
    t = sum(sum(temp));
    if(t == 0)
        xxx(i) = 1;
    end
end
      