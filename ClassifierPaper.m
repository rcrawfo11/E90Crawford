%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%E90: P300 Offline Implementation
%Spring 2021
%Code by Rekha Crawford
%
%Description: 
%Loads data for specified participant number, creates K-Folds, runs
%classifer, makes confusion matricies, saves data to "Data/paperA0x" where
%where x is the participants number 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load and unpack data
%Spliced file created in epoch splicing, change participant number to load
%in data from different partipants 
clear ~acc_train_avg ~acc_test_avg ~acc_all_test ~acc_all_train
close all

participant = '7';
load("Data/paperA0" + participant); 
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
kfolds = 5; 
rng('default') 

shuffle = randperm(length(y_trial)); 
shuffle_trials = X(shuffle, :, :); 
shuffle_label = y_trial(shuffle);

targ_class = shuffle_trials(shuffle_label == 2, :, :);
targ_label = shuffle_label(shuffle_label == 2);

non_targ_class = shuffle_trials(shuffle_label == 1, :, :); 
non_targ_label = shuffle_label(shuffle_label == 1); 

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
close all
clear acc_test acc_train
undersamp = true;

vals = linspace(1, kfolds, kfolds); 

for i = 1:kfolds
    clear train y_train test y_test
    
    test = folds{i, 1}; 
    y_test = folds{i, 2};
    
    if undersamp 
        train_unsamp = cell2mat(folds(vals ~= i, 1)); 
        y_train_unsamp = cell2mat(folds(vals ~= i, 2));

        j = [2 1];
        for k = 1:2
            index = find(y_train_unsamp == j(k));
            samp = randsample(length(index), 440*k); 
            train{k} = train_unsamp(index(samp), :, :);  
            y_train{k} = y_train_unsamp(index(samp));
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
    
    acc_train(i) = (nnz((class_pred==y_train))/numel(class_pred))
    acc_test(i) = (nnz((test_pred==y_test))/numel(test_pred))

    
    
    [confmat, order] = confusionmat(y_train, class_pred);
    [confmat_test, order] = confusionmat(y_test, test_pred);
    
    figure; 
    cmTrain = confusionchart(confmat, ["Non-Target", "Target"], 'RowSummary', 'row-normalized');
    cmTrain.title(sprintf("Train set: Fold %d", i))
    figure;
    cmTest = confusionchart(confmat_test, ["Non-Target", "Target"], 'RowSummary', 'row-normalized');
    cmTest.title(sprintf("Test set: Fold %d", i))
end 

train_avg = mean(acc_train)
test_avg = mean(acc_test)

acc_train_avg = train_avg + acc_train_avg;
acc_test_avg = acc_test_avg + test_avg;
%% Save Data
save("Data/feats"+participant, 'X', 'X_trial', 'y_trial', 't', 'fs'); 