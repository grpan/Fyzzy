t = tiledlayout(2,3);
[X,Y,Z] = peaks;

% Tile 1
nexttile
contour(X,Y,Z)

% Span across two rows and columns
nexttile([2 2])
contourf(X,Y,Z)

% Last tile
nexttile
imagesc(Z)