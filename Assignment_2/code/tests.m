fis_str = car.fis;
x = linspace(0,1,100);
y = ones(1, length(x));
for i=1:length(x)
    y(i) = evalfis(fis_str, [x(i), 1, 0]);
end


plot(x, y);
