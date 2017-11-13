n = 5;
theta = -90:1:90; 
tau = 0:(1.0 * 10^-9):(100 * 10^-9);
x1 = Pmusics{n};
x2 = p1_without_transe{n};
judge = x1 == x2;
[aoa, tof] = meshgrid(theta, tau);
figure(1);
mesh(aoa, tof, x1');
figure(2);
mesh(aoa, tof, x2');
len1 = size(Pmusics, 1);
len2 = size(p1_without_transe, 1);
flags = zeros(len1, 1);
for ii = 1 : len1
    x1 = Pmusics{ii};
    x2 = p1_without_transe{ii};
    temp = x1 ~= x2;
    if sum(sum(temp)) == 0
        flags(ii) = 1;
    end
end
flags