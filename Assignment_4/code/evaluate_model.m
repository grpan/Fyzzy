function [error_matrix, OA, PA, UA, Khat] = evaluate_model(valData, valError, valFis, trnData, trnError, i, classes, plot_flag)

if plot_flag == true
    f = figure("Visible","off");
    plot([trnError valError],'LineWidth',1.5); grid on;
    xlabel('# of Iterations'); ylabel('Error');
    legend('Training Error','Validation Error');
    title(valFis.Name + ' - Validation');

    plot_mfs(valFis,size(trnData,2)-1);
    exportgraphics(f, "../images/" + " Hybrid Training " +  valFis.Name +  '.png', 'Resolution',200);
end

% Confusion Matrix
Yval=evalfis(valFis, valData(:,1:end-1));
if max(valFis.Outputs.Range) < 4
    Yval = discretize(Yval, [-100 1.5 100]);
else
    Yval = discretize(Yval, [-100 sort(classes(1:end-1))+0.5 100]);
end
assert(~any(isnan(Yval)));
error_matrix = confusionmat(valData(:,end),Yval);

% Overall Accuracy
N = length(Yval);
OA = sum(diag(error_matrix))/ N;

% Producer's accuracy - User's accuracy
PA = diag(error_matrix) ./ sum(error_matrix, 2);
UA = diag(error_matrix) ./ sum(error_matrix, 1).';

% Kappa statistic
S = sum(error_matrix, 1) * sum(error_matrix, 2);
assert(isscalar(S));
Khat = (N*sum(diag(error_matrix))-S) / (N^2-S);

% Plot Confusion-Error Matrix
if plot_flag == true
    f = figure("Visible","off");
    confusionchart(error_matrix);
    title(valFis.Name + ' - Error Matrix');
    exportgraphics(f, "../images/" + " Error Matrix " +  valFis.Name +  '.png', 'Resolution',200);
    close(f);

    f = figure("Visible","off");
    len = length(PA);
    b = bar([OA PA' UA' Khat], 'FaceColor','flat');
    b.CData = repelem(1:4,[1 len len 1]);
    xticks(cumsum([1 1+(len-1)/2 len 1+(len-1)/2]));
    xticklabels({'OA', 'PA', 'UA', 'Khat'});
    title(valFis.Name + ' - Performance');
    exportgraphics(f, "../images/" + " Performance " +  valFis.Name +  '.png', 'Resolution',200);
    close(f);
end
end