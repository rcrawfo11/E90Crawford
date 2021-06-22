%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Splicing our data into epochs and then Extracting Features to feed the 
% classifier! yayyyyyy
% Mainly just going thru our processed data and getting the trial periods
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load in Data
clear ~participant 

participant = 'A07';
load("Data/preprocessed"+participant);  
X = cell([5,1]);

%% Get indices of stimulus onset 
y_start = zeros(size(y_stim_down));
ind = 1; 
for i = 2:length(y_stim_down)
    if y_stim_down(i) ~= y_stim_down(i-1) && y_stim_down(i) ~=0
        y_start(i) = 1;
        y_start_ind(ind) = i; 
        ind = ind +1; 
    end
end 
%% Splice 
% Splicing into cell array since that's one of the easier arrays to mess
% with
%We're grabbing the 50 ms before and the 500 ms after any given stimulus
%it's possible all we need is the 200-500 ms after 
pre_ms = 0;
post_ms = 1000; 
pre_stim_length = round(pre_ms*.001*fs);
post_stim_length = round(post_ms*.001*fs);

t = linspace(-pre_ms, post_ms, pre_stim_length+post_stim_length+1);

X_trial = zeros([sum(y_start), pre_stim_length+post_stim_length+1, 8]);   

for i = 1:sum(y_start) 
    X_trial(i, :, :) = X_scale(y_start_ind(i)-pre_stim_length:y_start_ind(i)+post_stim_length, :);
    y_trial(i) = y_down(y_start_ind(i));
    y_val(i) = y_stim_down(y_start_ind(i));
end 

%% PCA 
% Runs PCA on trial and pulls out first 3 components, uses those as
% features
% In general, 90% of the variance is captured by the 

num_components = 3;
X_combined = zeros([sum(y_start), pre_stim_length+post_stim_length+1, num_components]);  

for i = 1:length(X_trial(:, 1, 1)) 
    [coeff,score,latent,tsquared,explained,mu] = pca(squeeze(X_trial(i, :, :)));
    X_combined(i, :, :) = score(:, 1:num_components);
end 

X{1} = X_combined;
%% Basic Average 
% Takes average of channels for the trial time frame 
% can also also include variance, if you want the variance as a feature set
% want var to true
clear want_var

want_var = false;

X_avg = zeros([sum(y_start), pre_stim_length+post_stim_length+1, 1]); 
for i = 1:length(X_trial(:, 1, 1)) 
    X_avg(i, :, 1) = mean(squeeze(X_trial(i, :, :)), 2);
    if want_var
        X_avg(i, :, 2) = mean(squeeze(X_trial(i, :, :)), 2);
    end
end 


X{2} = X_avg;
%% Avergaged over bins
% Takes different time frames from the study and finds the average across 
% Channels and across time
% Uses those as the features for classification 
% To change the time frames, change the number of bins
% Can also use var, if you want the variance set want_var to true
clear want_var 

want_var = false; 

num_bin = 4; 
bin_length = round((pre_stim_length + post_stim_length)/num_bin)-1;
X_bin = zeros([sum(y_start), num_bin, 1]); 
for i = 1:length(X_trial(:, 1, 1)) 
    for j = 1:num_bin
        x = squeeze(X_trial(i, bin_length*(j-1)+1:bin_length*j, :));
        X_bin(i, j, 1) = mean(mean(x));
        if want_var
            X_bin(i, j, 2) = var(var(x)); 
        end 
    end
end 

X{3} = X_bin;

%% Max over bins
% Takes different time frames from the study and finds the average across 
% Channels and across time
% Uses those as the features for classification 
% To change the time frames, change the number of bins
% Can also use var, if you want the variance set want_var to true
clear want_var 

want_var = false; 

num_bin = 6; 
bin_length = round((pre_stim_length + post_stim_length)/num_bin)-1;
X_bin = zeros([sum(y_start), num_bin, 8]); 
for i = 1:length(X_trial(:, 1, 1)) 
    for j = 1:num_bin
        x = squeeze(X_trial(i, bin_length*(j-1)+1:bin_length*j, :));
        X_bin(i, j, :) = max(x);
    end
end 

X{4} = X_bin;

%% Max of the Power Spectrum 
% Just using the maximum of the power spectrum for each channel can we
% predict the P300? 
% The anwser? No, no it cannot, I'm assuming too much variance
rel_f = fs/2;
chans = [1 2 7 8];
X_pow = zeros([sum(y_start), rel_f, length(chans)]); 
for i = 1:length(X_trial(:, 1, 1)) 
    for j = 1:length(X_pow(1, 1, :)) 
        [power, f] = spectral(X_trial(i, :, chans(j)), fs, false); 
        X_pow(i, :,j) = power(1:rel_f); 
    end 
end 

X{5} = X_pow;

%% Save Data
save("Data/spliced"+participant, 'X', 'X_trial', 'y_trial', 't', 'fs'); 

