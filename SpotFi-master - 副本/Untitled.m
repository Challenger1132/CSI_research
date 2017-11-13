
n = 1000;
x = round(rand(n,n)*100);
tic;
temp1 = 0;
for index1 = 1 : size(x,1)
    for index2 = 1 : size(x,2);
        if x(index1, index2) < 50
            break;
        end
        temp1 = temp1 + 1;
    end
end
temp1;
toc

tic;
y = x >= 50;
temp2 = sum(sum(y));
toc

tic;
y = find(x >= 50);
temp3 = length(y);
toc