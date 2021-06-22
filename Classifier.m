%% Load and unpack data
%Spliced file created in epoch splicing 
clear
close all

participant = 'A01';
load("Data/spliced" + participant); 

%% Getting it ready for classifier 
% % We need to grab the labels for each trial, multiply them by 3 and prep
% % each component 
% %
% % Set num to what kind of spatial filtering you want
% % 1. PCA 
% % 2. Basic average (with or without variance) 
% % 3. Binned average (with or without variance)
% % 4. First Two Channels and Power of First Two Channels
% % 5. Just the max of the spectrums (does not work)
% 
% clear train y_train test y_test
% num = 1;
% rng('default')
% 
% for i = 1:2
%     index = find(y_trial == i);
%     samp = randsample(length(index), 700); 
%     train{i} = X{num}(index(samp), :, :);  
%     y_train{i} = y_trial(index(samp));
% end 
% 
% train = [train{1}; train{2}];
% y_train = [y_train{1} y_train{2}]'; 
% 
% dim = size(train);
% 
% shuffle = randperm(dim(1)); 
% 
% train = train(shuffle,:,:);
% y_train = y_train(shuffle);
% 
% if length(dim) > 2
%     train = reshape(train, [dim(1), dim(3)*dim(2)]); 
%     %y_train = repelem(y_train, dim(3)); 
% else 
%     train = train; 
%     y_train = y_train;
% end

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
num = 1;
kfolds = 5; 
rng('default') 

shuffle = randperm(length(y_trial)); 
shuffle_trials = X{num}(shuffle, :, :); 
shuffle_label = y_trial(shuffle);

stim_class = shuffle_trials(shuffle_label == 2, :, :);
stim_label = shuffle_label(shuffle_label == 2);

non_stim_class = shuffle_trials(shuffle_label == 1, :, :); 
non_stim_label = shuffle_label(shuffle_label == 1); 

stim_bins = round(length(stim_label)/kfolds);
non_stim_bins = round(length(non_stim_label)/kfolds); 

folds = cell(kfolds, 2); 


%Sample for kfolds with the same distrubution as the data
for i = 1:kfolds
    folds{i, 1} = [stim_class(1+stim_bins*(i-1):stim_bins*i, :, :); non_stim_class(1+non_stim_bins*(i-1):non_stim_bins*i, :, :)];
    folds{i, 2} = [stim_label(1+stim_bins*(i-1):stim_bins*i) non_stim_label(1+non_stim_bins*(i-1):non_stim_bins*(i))]';
    
    shuffle = randperm(length(folds{i, 2})); 
    
    folds{i, 1} = folds{i, 1}(shuffle, :, :); 
    folds{i, 2} = folds {i, 2}(shuffle); 
end 

%% Classifier 
close all
undersamp = false; 

vals = linspace(1, kfolds, kfolds); 
for i = 1:kfolds
    clear train y_train test y_test
    
    test = folds{i, 1}; 
    y_test = folds{i, 2};
    
    if undersamp 
        train_unsamp = cell2mat(folds(vals ~= i, 1)); 
        y_train_unsamp = cell2mat(folds(vals ~= i, 2));

        j = [2 1];
        for i = 1:2
            index = find(y_train_unsamp == j(i));
            samp = randsample(length(index), 500*i); 
            train{i} = train_unsamp(index(samp), :, :);  
            y_train{i} = y_train_unsamp(index(samp));
        end 

        train = [train{1}; train{2}];
        y_train = [y_train{1}' y_train{2}']'; 

        dim = size(train);

        shuffle = randperm(dim(1)); 

        train = train(shuffle,:,:);
        y_train = y_train(shuffle);
    else 
        train = cell2mat(folds(vals ~= i, 1)); 
        y_train = cell2mat(folds(vals ~= i, 2));
    end 

    dim = size(train);
    dim_test = size(test); 
    
    if length(dim) > 2
        train = reshape(train, [dim(1), dim(3)*dim(2)]); 
        test = reshape(test, [dim_test(1), dim_test(3)*dim_test(2)]);
    end
    
    classifier = fitcdiscr(train, y_train);
    test_pred = predict(classifier, test); 
    class_pred =  predict(classifier, train); 
    acc_test = (nnz((test_pred==y_test))/numel(test_pred))
    acc_train = (nnz((class_pred==y_train))/numel(class_pred))
    
    [confmat, order] = confusionmat(y_train, class_pred);
    [confmat_test, order] = confusionmat(y_test, test_pred);
    
    figure; 
    cmTrain = confusionchart(confmat, ["Non-Target", "Target"], 'RowSummary', 'row-normalized');
    cmTrain.title(sprintf("PCA Train set: Fold %d", i))
    figure;
    cmTest = confusionchart(confmat_test, ["Non-Target", "Target"], 'RowSummary', 'row-normalized');
    cmTest.title(sprintf("PCA Test set: Fold %d", i))
    
end 

%% Save Data
save("Data/feats"+participant, 'X', 'X_trial', 'y_trial', 't', 'fs'); 
