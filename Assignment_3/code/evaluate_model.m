function Perf = evaluate_model(valData, valError, valFis, trnData, trnError, trnFis, Perf , i)

% Evaluation function
Rsq = @(ypred,y) 1-sum((ypred-y).^2)/sum((y-mean(y)).^2);

f = figure("Visible","off");
plot([trnError valError],'LineWidth',1.5); grid on;
xlabel('# of Iterations'); ylabel('Error');
legend('Training Error','Validation Error');
title(valFis.Name + ' - Validation');

% figure;
plot_mfs(valFis,size(trnData,2)-1);

exportgraphics(f, "../images/" + " Hybrid Training " +  valFis.Name +  '.png', 'Resolution',200);




Yval=evalfis(valFis, valData(:,1:end-1));
PredErrorVal = Yval - valData(:,end);
rmse(1) = sqrt(mse(Yval,valData(:,end)));

Yvaltrn=evalfis(valFis, trnData(:,1:end-1));
PredErrorValTrn = Yvaltrn - trnData(:,end);
rmse(2) = sqrt(mse(Yvaltrn,trnData(:,end)));


Ytrnval=evalfis(trnFis, valData(:,1:end-1));
PredErrortrnVal = Ytrnval - valData(:,end);
rmse(3) = sqrt(mse(Ytrnval,valData(:,end)));


Ytrntrn=evalfis(trnFis, trnData(:,1:end-1));
PredErrortrnTrn = Ytrntrn - trnData(:,end);
rmse(4) = sqrt(mse(Ytrntrn,trnData(:,end)));
% categories = categorical(["Yval" "Yvaltrn" "Ytrntrn" "Ytrnval"]);

idxvector = [ones(size(PredErrorVal)) ;2*ones(size(PredErrorValTrn)); 3*ones(size(PredErrortrnVal)); 4*ones(size(PredErrortrnTrn))];
x = categorical(idxvector, [1 2 3 4], {'Yval' 'Yvaltrn' 'Ytrnval' 'Ytrntrn'});

f = figure("Visible","off");
swarmchart(x, [PredErrorVal;PredErrorValTrn;PredErrortrnVal;PredErrortrnTrn], 8, ...
    'filled','MarkerFaceAlpha',0.5,'MarkerEdgeAlpha',0.5, 'XJitter','density');
ylabel("Prediction Error")

exportgraphics(f, "../images/" + " Prediction Errors " +  valFis.Name +  '.png', 'Resolution',200);


R2=Rsq(Yval,valData(:,end));
RMSE=sqrt(mse(Yval,valData(:,end)));
NMSE = 1 - R2;
NDEI = sqrt(NMSE);
Perf(i,:)={RMSE R2 NMSE NDEI};


end