%% Load and unpack data
%Spliced file created in epoch splicing 
clear
close all

participant = 'A07.mat';
load("paper" + participant); 
%% K-Fold Validation 
% We need to grab the labels for each trial, multiply them by 3 and prep
% each component 
%
% Set num to what kind of spatial filtering you want
% 1. PCA 
% 2. Basic average (with or without variance) 
% 3. Binned average (with or without variance)
% 4. First Two Channels and Power of First Two Channels
% 5. Just the max of the spectrums (does not work)
clear train y_train test y_test
kfolds = 7; 
rng('default') 

shuffle = randperm(length(y_trial)); 
shuffle_trials = X(shuffle, :, :); 
shuffle_label = y_trial(shuffle);

targ_class = shuffle_trials(shuffle_label == 2, :, :);
targ_label = shuffle_label(shuffle_label == 2);

non_targ_class = shuffle_trials(shuffle_label == 1, :, :); 
non_targ_label = shuffle_label(shuffle_label == 1); 

%targ_class = X(y_trial==2,:,:);
%targ_label = y_trial(y_trial==2);

%non_targ_class = X(y_trial==1,:,:);
%non_targ_label = y_trial(y_trial==1);

targ_bins = round(length(targ_label)/kfolds)-1;
non_targ_bins = round(length(non_targ_label)/kfolds)-1; 

folds = cell(kfolds, 2); 


%Sample for kfolds with the same distrubution as the data
for i = 1:kfolds
    folds{i, 1} = [targ_class(1+targ_bins*(i-1):targ_bins*i, :, :); non_targ_class(1+non_targ_bins*(i-1):non_targ_bins*i, :, :)];
    folds{i, 2} = [targ_label(1+targ_bins*(i-1):targ_bins*i) non_targ_label(1+non_targ_bins*(i-1):non_targ_bins*(i))]';
    
    shuffle = randperm(length(folds{i, 2})); 
    
    folds{i, 1} = folds{i, 1}(shuffle, :, :); 
    folds{i, 2} = folds {i, 2}(shuffle); 
end 

%% Classifier 
%First Kfolds
%rng('default') % For reproducibility
%n = length(X_combined(:, 1, 1));
%trial_partition = cvpartition(n,'Kfold',5); % Nonstratified partition
%idxTrain = trail;
%tblTrain = tbl(idxTrain,:);
%idxNew = test(hpartition);
%tblNew = tbl(idxNew,:);
close all

vals = linspace(1, kfolds, kfolds); 
for i = 1:kfolds
    clear train y_train test y_test
    
    test = folds{i, 1}; 
    y_test = folds{i, 2};
    
%    train = cell2mat(folds(vals ~= i, 1)); 
%    y_train = cell2mat(folds(vals ~= i, 2));
    
    train_unsamp = cell2mat(folds(vals ~= i, 1)); 
    y_train_unsamp = cell2mat(folds(vals ~= i, 2));
%     
    j = [2 1];
    for k = 1:2
        index = find(y_train_unsamp == j(k));
        samp = randsample(length(index), 480*k); 
        train{k} = train_unsamp(index(samp), :, :);  
        y_train{k} = y_train_unsamp(index(samp));
    end 
% 
    train = [train{1}; train{2}];
    y_train = [y_train{1}' y_train{2}']'; 
% 
    dim = size(train);
% 
    shuffle = randperm(dim(1)); 
% 
    train = train(shuffle,:,:);
    y_train = y_train(shuffle);

%    dim = size(train);
    dim_test = size(test); 
    
    if length(dim) > 2
        train = reshape(train, [dim(1), dim(3)*dim(2)]); 
        test = reshape(test, [dim_test(1), dim_test(3)*dim_test(2)]);
    end
    
    classifier = fitcdiscr(train, y_train);
    test_pred = predict(classifier, test); 
    class_pred =  predict(classifier, train);
    
    acc_test(i) = (nnz((test_pred==y_test))/numel(test_pred));
    acc_train(i) = (nnz((class_pred==y_train))/numel(class_pred));
    
    acc_test_targ(i) = nnz([test_pred==2]&[y_test==2])/nnz(y_test==2);
    acc_test_nontarg(i) = nnz([test_pred==1]&[y_test==1])/nnz(y_test==1);
    
    acc_train_targ(i) = nnz([class_pred==2]&[y_train==2])/nnz(y_train==2);
    acc_train_nontarg(i) = nnz([class_pred==1]&[y_train==1])/nnz(y_train==1);
       
    [confmat, order] = confusionmat(y_train, class_pred);
    [confmat_test, order] = confusionmat(y_test, test_pred);
    
    %figure; 
    %confusionchart(confmat);
    %title('Train set')
    %figure;
    %confusionchart(confmat_test);
    %title('Test set')
end 

fprintf("Average Test Score: %3.2f\n",mean(acc_test)*100);
fprintf("Average Train Score: %3.2f\n",mean(acc_train)*100);
fprintf("Average Test Target Score: %3.2f\n",mean(acc_test_targ)*100);
fprintf("Average Test NonTarg Score: %3.2f\n",mean(acc_test_nontarg)*100);
fprintf("Average Train Target Score: %3.2f\n",mean(acc_train_targ)*100);
fprintf("Average Train NonTarg Sscore: %3.2f\n",mean(acc_train_nontarg)*100);
%% Save Data
save("feats"+participant, 'X', 'X_trial', 'y_trial', 't', 'fs'); 