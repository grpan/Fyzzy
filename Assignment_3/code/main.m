clc; clear; close all;

%% Load data - Split data
data=load('../datasets/airfoil_self_noise.dat');
preproc=1;
[trnData,valData,~]=split_scale(data,preproc);

% Perf=zeros(4,4);

varTypes = {'double','double','double','double'};
varNames = {'RMSE','R2','NMSE','NDEI'};
Perf = table('Size',[4 4],'VariableTypes',varTypes,'VariableNames', varNames);

rng('default');
%% TSK Models
fprintf("Training of the 4 TSk Models... \n");
opt = genfisOptions('GridPartition');
opt.InputMembershipFunctionType = "gbellmf";
opt_num_mfs = [2 3 2 3];
opt_output_mfs_types = ["constant", "constant", "linear", "linear"];

times = zeros(1,4);
for i = 1:4
    opt.NumMembershipFunctions = opt_num_mfs(i);
    opt.OutputMembershipFunctionType = (opt_output_mfs_types(i));

    fis=genfis(trnData(:,1:end-1), trnData(:,end),opt);
    fis.Name = "TSK model " + i;
    
    % Plot Initial MFs
    plot_mfs(fis,size(trnData,2)-1);
    % Configure and Train
    tic
    [trnfis,trnError,~,valFis,valError] = tsk_train(fis, trnData, valData, 100);
    times(i) = toc;

    % Model Evaluation
    Perf = evaluate_model(valData, valError, valFis, trnData, trnError, trnfis, Perf , i);
    
end

fprintf("Time it took to train the models: %3.2f %3.2f %3.2f %3.2f. \n", times);

disp(Perf);

%% High Dimensions - grid Search
data = load('../datasets/superconduct.csv');
preproc=1;
[trnData,valData,tstData]=split_scale(data,preproc);
data = [trnData; valData; tstData];

radii = [0.2 0.4 0.6 0.8];
num_features = [2 4 8 10 12];

tic;
[idx,~] = relieff(data(:,1:end-1), data(:,end),8);
% [idx, ~] = fsrmrmr(data(:,1:end-1), data(:,end));
t = toc;
fprintf("Feature selection took %.1f seconds.\n", t);

kfold = 5;

% Perform Grid search for radii and num_features
kf_partition = cvpartition(length(data), 'KFold', 5);
kfPerf = zeros(length(num_features),length(radii),kfold,4);
Rsq = @(ypred,y) 1-sum((ypred-y).^2)/sum((y-mean(y)).^2);
error_score = zeros(length(num_features),length(radii));
tic
for i = 1:length(num_features)
    Data_pruned = [data(:,idx(1:num_features(i)))  data(:,end)];
    for j = 1:length(radii)
        for k = 1:kfold
            idx_test = test(kf_partition,k);
            idx_train = training(kf_partition,k);


            opt = genfisOptions("SubtractiveClustering", "ClusterInfluenceRange", radii(j));
            fis = genfis(Data_pruned(idx_train, 1:end-1), Data_pruned(idx_train, end), opt);
            fis.Name = sprintf("K-fold %d, %2f", num_features(i), radii(j));
            [~,trainError,~,valFis,valError] = tsk_train(fis, Data_pruned(idx_train,:), ...
                Data_pruned(idx_test,:), 100);
   
            error_score(i,j) = error_score(i,j) + mean(valError);

            Yval=evalfis(valFis, Data_pruned(idx_test,1:end-1));
            R2=Rsq(Yval,Data_pruned(idx_test,1:end-1));
            RMSE=sqrt(mse(Yval,Data_pruned(idx_test,1:end-1)));
            NMSE = 1 - R2;
            NDEI = sqrt(NMSE);
            kfPerf(i,j,k,:)=[RMSE R2 NMSE NDEI];            
        end
    end
end
t = toc;
fprintf("K-fold took %.1f seconds.\n", t);

[~, I] = min(error_score,[],'all');
[r, c] = ind2sub( [length(num_features) length(radii)], I );
fprintf("Features: %d (index: %d).  Radius: %.2f (index: %d) \n", num_features(r), r, radii(c), c);

f = figure;
surf(radii, num_features, error_score);
xticks(radii);
xlabel('Radius (r_a)');
yticks(num_features);
ylabel('number of Features');
view(-120, 20);
exportgraphics(f, "../images/" + " Grid Search error" +  '.png', 'Resolution',250);

%% High Dimensions - Final Model


% Training for 8 features and 0.2 radius
trnData = [trnData(:,idx(1:num_features(r)))  trnData(:,end)];
valData = [valData(:,idx(1:num_features(r)))  valData(:,end)];
tstData = [tstData(:,idx(1:num_features(r)))  tstData(:,end)];

opt = genfisOptions("SubtractiveClustering", "ClusterInfluenceRange", radii(c));
fis = genfis(trnData(:, 1:end-1), trnData(:, end), opt);

fis.Name = sprintf("Final Model - Untrained (Features: %d , Radius: %.2f)", num_features(r), radii(c));

% Plot and Train
plot_mfs(fis, num_features(r));
fis.Name = sprintf("Final Model - Trained (Features: %d , Radius: %.2f)", num_features(r), radii(c));
[trnfis,trnError,stepSize,valFis,valError] = tsk_train(fis,trnData, valData, 200);
% plot_mfs(trnfis, num_features(r));

% Model Evaluation
FinalPerf = table('Size',[1 4],'VariableTypes',varTypes,'VariableNames', varNames);
FinalPerf = evaluate_model(valData, valError, valFis, trnData, trnError, trnfis, FinalPerf , 1);
disp(FinalPerf);