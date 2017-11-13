x = -3:0.01:3;
y = -2:0.01:2;
[xx, yy] = meshgrid(x, y);
zz = xx.*exp(-(xx.^2+yy.^2));
mesh( yy, xx,  zz);
xlabel('x');
ylabel('y');
zlabel('z');
