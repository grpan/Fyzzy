%% Split - Preprocess Data
%tsk_train - Configure And train the TSK model.

function [trnfis,trainError,stepSize,chkFIS,chkError] = tsk_train(fis, trnData, valData, epochnumber)

    fis.Name = fis.Name + " Trained";
    
    % Congigure
    opt = anfisOptions('InitialFIS', fis, 'EpochNumber', epochnumber);
    opt.ValidationData = valData;

    % Disable Output
    opt.DisplayANFISInformation = 0;
    opt.DisplayErrorValues = 0;
    opt.DisplayStepSize = 0;
    opt.DisplayFinalResults = 0;
    
    [trnfis,trainError,stepSize,chkFIS,chkError] = anfis(trnData,opt);


end
