%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Spatially filtering and then Splicing our data into epochs to feed the 
% classifier! yayyyyyy
% Mainly just going thru our processed data and getting the trial periods
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load in Data
clear
load preprocessed 

%% Spatial first 
%[coeff,score,latent,tsquared,explained,mu] = pca(X_scale);
%X_scale = score(:, 1:4); 

%rows time, cols electrodes, do PCA on that run on each epoch, latent are eigen values, 
%normalize

%% Splice 
% Splicing into cell array since that's one of the easier arrays to mess
% with

epoch_length =0.600*fs;
X_tmat = zeros([(length(trial)*epoch_length), 8]); 
for i = 1:length(trial)
    X_trial{i} = X_scale(trial(i):trial(i)+epoch_length-1, :);
    index = epoch_length*(i-1)+1;
    X_tmat(index:index+epoch_length-1, 1:8) = X_scale(trial(i):trial(i)+epoch_length-1, :);
    y_trial(i) = y_down(trial(i));
end

%% Spatial filter
% Will implement CCA later, for now using PCA for ease of implementation

%[coeff,score,latent,tsquared,explained,mu] = pca(X_tmat);
%X_spa_filt = score(:, 1:4); 
%X_spa_filt = X_tmat;
X_spa_filt = reshape(X_spa_filt, [11200/35 4*35]);
y_trial_filt = repelem(y_trial, 4);

data_labeled = [X_spa_filt; y_trial_filt];

%% Splice 
% Splicing into cell array since that's one of the easier arrays to mess
% with

epoch_length =2.5*fs;
avg_length = 0.5*fs; 

num_rep = epoch_length/avg_length; 

X_tmat = zeros([(length(trial)*5), 8*length(y_trial)]); 
for i = 1:length(trial)
    for i = 1:num_rep
        X_trial{i} = X_scale(trial(i):trial(i)-1, :);
        y_trial(i) = y_down(trial(i));
    end
end

%% Above seems wrong 
% For the Epochs: 
% Trials last a bit, each trial contains many epochs, we need code to
% extract those
% Honestly,,, this should be it's own function so we can grab


