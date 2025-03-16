clc;clear;close all;
% fis = readfis('car_controller_satl_mfedited');
fis = readfis('car_controller_satl');
f = figure;
axis equal

area( [5 5 6 6 7 7 10 10],[0 1 1 2  2 3 3 0], 'FaceColor',0.5*ones(1,3), FaceAlpha=0.5)
axis([4 11 0 5]);
set(gca,'DataAspectRatio',[1 1 1])
hold on

dim = 50;
% x = linspace(1,4,dim) ;
% y = linspace(1,4,dim) ;
x = linspace(4,8,dim) ;
y = linspace(0,5,dim) ;
[X,Y] = meshgrid(x,y) ;
plot(X,Y,'.r', 'MarkerSize', 1)



% [DH, DY] = sense([X(:), Y(:)])

DH = zeros(size(X));
DV = zeros(size(Y));

artgridx = zeros(size(X));
artgridy = zeros(size(Y));

for i = 1:length(x)
    for j = 1:length(y)

        % [DH(j,i), DV(i,j)] = sense([x(i), y(j)]);
        % [DH(i,j), DV(j,i)] = sense([x(i), y(j)]);

        [DH(j,i), DV(j,i)] = sense([x(i), y(j)]);
        % [DH(i,j), DV(i,j)] = sense([x(i), y(j)]);
        
        artgridx(j,i) = x(i);
        artgridy(i,j) = y(i);
    end
end

zh = DH < 0;
zv = DV < 0;
DH(DH < 0) = 0.5;
DV(DV < 0) = 0.5;

XY = [X(:),Y(:), zeros(dim^2,1)];

res = evalfis(fis, [DH(:),DV(:), repmat(90, [dim^2 1]) ]);

[u,v] = pol2cart(1,deg2rad(res+0));
u = reshape(u, [dim dim]);
v = reshape(v, [dim dim]);

u(zh) = 0;
v(zv) = 0;

quiver(X, Y, u, v)