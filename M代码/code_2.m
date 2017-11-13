x = rand(1,1000);
y = linspace(min(x), max(x), 1000);
cocnt = hist(x,y);
p = cocnt / length(x);
subplot(221);
bar(y,p);
subplot(222);
hist(x,y);
