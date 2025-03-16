clc; clear; close all;
% rng('default');

%% Load data - Split data
data=load('../datasets/haberman.data');
preproc=1;
[trnData,valData,~]=split_scale(data,preproc); % TODO: Ensure sample frequency uniform among datasets

% Perf=zeros(4,4);

varTypes = {'double','double','double','double'};
varNames = {'OA','PA','UA','Khat'};
Perf = table('Size',[4 4],'VariableTypes',varTypes,'VariableNames', varNames);


%% 4 TSK ModelsP
fprintf("Training of the 4 TSk Models... \n");
times = zeros(1,4);
model_config = [false 0.2; false 0.8; true 0.2; true 0.8];
for i = 1:4

    fis=gen_fis(model_config(i,1), trnData, model_config(i,2), false);
    fis.Name = "TSK model " + i;
    
    % Plot Initial MFs
    plot_mfs(fis,size(trnData,2)-1);
    % Configure and Train
    tic
    [~,trnError,~,valFis,valError] = tsk_train(fis, trnData, valData, 100);
    times(i) = toc;

    % Model Evaluation
    [error_matrix, OA, PA, UA, Khat] = evaluate_model(valData, valError, valFis, trnData, trnError, i, [], true);
    Perf(i,:) = {OA sum(PA)/2 sum(UA)/2 Khat};
end

fprintf("Time it took to train the models: %3.2f %3.2f %3.2f %3.2f. \n", times);
disp(Perf)

%% High Dimensions - grid Search
data = readmatrix('../datasets/epileptic_seizure_data.csv');
data(:,1) = [];
preproc=1;
[trnData,valData,tstData]=split_scale(data,preproc);
data = [trnData; valData; tstData];

radii = [0.2 0.4 0.6 0.8 ];
num_features = [4 8 10 12];

tic;
[idx,~] = relieff(data(:,1:end-1), data(:,end),8);
% [idx, ~] = fsrmrmr(data(:,1:end-1), data(:,end));
% idx = [59	58	113	84	115	83	114	53	52	87	85	82	76	51	122	116	75	60	50	79	117	62	142	143	80	145	...
%     155	146	49	22	118	61	10	139	133	23	154	86	11	140	12	144	103	24	138	21	135	141	74	77	102	112	81	...
%     101	48	119	99	134	156	136	88	123	54	148	13	147	120	25	153	9	100	57	78	63	132	167	121	137	169	20	64	56	...
%     8	98	7	124	55	176	65	14	47	168	126	111	42	104	157	175	166	26	127	44	129	152	73	106	125	15	165	177	35	41	170	151	37	16	107	...
%     149	150	90	40	19	94	43	164	130	66	67	30	38	17	108	110	89	36	68	72	93	6	128	71	39	174	105	95	31	163	27	158	18	46	...
%     91	162	45	29	109	178	161	171	4	96	92	97	28	160	70	3	34	2	32	131	69	5	1	159	33	173	172]; % instead of relieff
t = toc;
fprintf("Feature selection took %.1f seconds.\n", t);

kfold = 5;

% Perform Grid search for radii and num_features
kf_partition = cvpartition(length(data), 'KFold', 5);
% kfPerf = zeros(length(num_features),length(radii),kfold,4);
kfPerf = {};
kfPerf = cell(length(num_features),length(radii),4);
Rsq = @(ypred,y) 1-sum((ypred-y).^2)/sum((y-mean(y)).^2);
error_score = zeros(length(num_features),length(radii));
classes = unique(data(:,end))';
nc = length(classes);


varTypes = {'double','double','double','cell','cell','double'};
varNames = {'feature','radius','OA','PA','UA','Khat'};
Perf = table('Size',[length(num_features)*length(radii) 6],'VariableTypes',varTypes,'VariableNames', varNames);


tic
for i = 1:length(num_features)
    Data_pruned = [data(:,idx(1:num_features(i)))  data(:,end)];
    for j = 1:length(radii)
        OA_s = 0; PA_s = classes*0; UA_s = classes*0; Khat_s = 0;
        for k = 1:kfold
            idx_test = test(kf_partition,k);
            idx_train = training(kf_partition,k);
        
            fis = gen_fis(true, Data_pruned(idx_train, 1:end), radii(j), true );

            fis.Name = sprintf("K-fold %d, %2f", num_features(i), radii(j));
            [trnFis,trainError,~,valFis,valError] = tsk_train(fis, Data_pruned(idx_train,:), ...
                Data_pruned(idx_test,:), 50);
   

            % Model Evaluation
            [error_matrix, OA, PA, UA, Khat] = evaluate_model(Data_pruned(idx_test,:), valError, valFis, ...
                Data_pruned(idx_train,:), trainError, i, classes, false);
            OA_s = OA_s + OA;
            PA_s = PA_s + PA;
            UA_s = UA_s + UA;
            Khat_s = Khat_s + Khat;
            
            error_score(i,j) = error_score(i,j) + mean(valError);

        end
        Perf((i-1)*length(radii) + j,:) = {num_features(i), radii(j), OA_s/kfold, PA_s/kfold, UA_s/kfold, Khat_s/kfold};
        fprintf('%d...',(i-1)*length(radii) + j);
    end
end
t = toc;
fprintf("   Done.\nK-fold took %.1f seconds.\n", t);
disp(Perf)

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

fis = gen_fis(true, trnData, radii(c), true);
fis.Name = sprintf("Final Model - Untrained (Features: %d , Radius: %.2f)", num_features(r), radii(c));

% Plot and Train
plot_mfs(fis, num_features(r));
fis.Name = sprintf("Final Model - Trained (Features: %d , Radius: %.2f)", num_features(r), radii(c));
[trnfis,trnError,stepSize,valFis,valError] = tsk_train(fis,trnData, valData, 200);
plot_mfs(trnfis, num_features(r));

% Model Evaluation
[Final_error_matrix, OA, PA, UA, Khat] = evaluate_model(valData, valError, valFis, trnData, trnError, i, classes, true);
disp(Final_error_matrix);
fprintf("Final Model: %.3f, OA(mean): %.3f, PA(mean): %.3f, Khat: %.3f\n", OA, mean(PA), mean(UA), Khat);
