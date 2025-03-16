function plot_mfs(fis, num_mfs)
%PlotMFs - Plot the MFs of a fis

    if num_mfs < 6
        size = [18 12];
    else
        size = [18 14];
    end

    [p, ~]  = numSubplots(num_mfs);
    p = [ceil(num_mfs/ceil(sqrt(num_mfs))) ceil(sqrt(num_mfs))];


    f = figure("Units", "centimeters", "Position", [0 0 size(1) size(2)], "Visible","off");
    
    tiledlayout(p(1), p(2), 'TileSpacing', 'tight', 'Padding', 'tight');
    % tiledlayout(2, 2, 'TileSpacing', 'tight', 'Padding', 'tight');
    sgtitle(fis.Name);

    for i = 1:num_mfs
        nexttile;
        [x, y] = plotmf(fis, 'input',i);
        plot(x,y, "LineWidth",0.8);

        
        set(gca,'linewidth',0.8)
        axis([x(1) x(end) 0 1]);
        xlabel(fis.Inputs(i).Name)

        if mod(i,p(2)) == 1
            ylabel('Degree of membership');
        end
    end

    exportgraphics(f, "../images/" + fis.Name + " MFs " + '.png', 'Resolution',200);
    close(f);
end

function [p,n]=numSubplots(n)
% function [p,n]=numSubplots(n)
%
% Purpose
% Calculate how many rows and columns of sub-plots are needed to
% neatly display n subplots. 
%
% Inputs
% n - the desired number of subplots.     
%  
% Outputs
% p - a vector length 2 defining the number of rows and number of
%     columns required to show n plots.     
% [ n - the current number of subplots. This output is used only by
%       this function for a recursive call.]
%
%
%
% Example: neatly lay out 13 sub-plots
% >> p=numSubplots(13)
% p = 
%     3   5
% for i=1:13; subplot(p(1),p(2),i), pcolor(rand(10)), end 
%
%
% Rob Campbell - January 2010
   
    
    while isprime(n) && n>4
        n=n+1;
    end
    
    p=factor(n);
    
    if isscalar(p)
        p=[1,p];
        return
    end
    
    
    while length(p)>2
        if length(p)>=4
            p(1)=p(1)*p(end-1);
            p(2)=p(2)*p(end);
            p(end-1:end)=[];
        else
            p(1)=p(1)*p(2);
            p(2)=[];
        end    
        p=sort(p);
    end
    
    
    %Reformat if the column/row ratio is too large: we want a roughly
    %square design 
    while p(2)/p(1)>2.5
        N=n+1;
        [p,n]=numSubplots(N); %Recursive!
    end

end


