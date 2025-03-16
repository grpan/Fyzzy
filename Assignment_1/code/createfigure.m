function createfigure(Name, labels, signals, zoomparams)

f = figure('visible','off');
% f = figure('visible','on');
ax = gca;
% ax.PlotBoxAspectRatio=[16/10 1 1];
set(gcf,'units','points','position',[10,10,800,500])
ax.FontSize = 12;
ax.TickDir = 'out';
ax.XGrid = 'on';
ax.YGrid = 'on';
hold on;
for sig = 1:length(signals)
    plot(signals(sig).Values, 'DisplayName',labels(sig) + signals(sig).Name, 'LineWidth',1); %);
end

title(Name);
lgd = legend('location', 'southeast');
xlabel('Time (seconds)');

% newx = 1 - ax.InnerPosition(1) - lgd.Position(1)%-ax.InnerPosition(3)%-(lgd.Position(1)+lgd.Position(3))+ax.InnerPosition(1);
newx = ax.InnerPosition(1)+3*(ax.InnerPosition(3)-(lgd.Position(1)+lgd.Position(3))+ax.InnerPosition(1));
newy = lgd.Position(2) + 2*(lgd.Position(2) - ax.InnerPosition(2));
newx2 = newx + 0.12 + (lgd.Position(1)-(newx+0.25) )/2;
newxx = [newx newx2];
if exist('zoomparams','var')
    for z = 1:size(zoomparams,1)
        % axes('position', [0.92-z*0.26 0.4 0.25 0.2], 'XLimitMethod', 'tight', 'YLimitMethod', 'padded', 'Box','on');
        axes('position', [newxx(z) newy 0.25 0.2], 'XLimitMethod', 'tight', 'YLimitMethod', 'padded', 'Box','on');
            for sig = 1:length(signals)
                hold on;
                indexOfInterest = ((signals(sig).Values.Time > zoomparams(z,1) & signals(sig).Values.Time < zoomparams(z,2) )); % range of t near perturbation
                plot(signals(sig).Values.Time(indexOfInterest), signals(sig).Values.Data(indexOfInterest), 'LineWidth',0.8) % plot on new axes
            end
        pbaspect([16/9 1 1])
    end
end
hold off;
exportgraphics(f, "../images/" + Name + ".png");
close(f);