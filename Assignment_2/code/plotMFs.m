function plotMFs(fis, filename)
%PlotMFs - Plot the MFs of a fis

    f = figure;
    for i = 1:4
        subplot(2,2,i);
        if i ~= 4
            plotmf(fis, 'input',i);
        else
            plotmf(fis, 'output',1);
        end
    end

    exportgraphics(f, "../images/" + filename + '.png', 'Resolution',500);

end
