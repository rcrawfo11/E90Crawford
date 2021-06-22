%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%E90: P300 Offline Implementation
%Spring 2021
%Code by Rekha Crawford
%
%Description:
% Using processing pipeline from paper consists of:
% Filtering (bandpass, notch)
% Epoch Splicing (800 ms from targulus onset)
% Artefact Rejection (-70 microvolts or 70 microvolts) 
% Baseline Correction (-200 ms from onset of epoch) 
% Feature Selection: Binned average 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unpack Data 
% Turn this into a function later
clear
close 

participant = "1";
load("Data/A0"+participant)
plotOn = true; 
[X, y, y_targ, trial, classes, classes_targ] = unpackData(data);
fs = 256; 

%% Filtering 
% Filter with a 0.5 Hz - 20 Hz Bandpass filter and notch
Wn = [0.5 10]/(fs/2);
[b, a] = butter(4, Wn, 'bandpass');
plotting = true;
t = linspace(1, 100/256*1000, 100); 
X_filt = filtfilt(b, a, X);

if plotOn
    close all;
    figure;
    hold on
    plot(t, X_filt(1:100, 1))
    plot(t, X(1:100, 1))
    title("Butterworth Filter Example") 
    legend("Filtered", "Unfiltered");
    ylabel("Voltage (microvolts)") 
    xlabel("Time (ms)") 

    figure; 
    hold on
    spectral(X, fs, plotting); 
    spectral(X_filt, fs, plotting); 
    legend("Unfiltered", "Filtered");
end

w0 = 50/(fs/2);  
bw = w0/35;
[b, a] = iirnotch(w0, bw); 
X_filt_notch = filter(b, a, X_filt); %Why filter not filtfilt?


if plotOn
    figure;
    hold on
    %plot(X_filt_notch(1:100, 1))
    plot(X_filt(1:100, 1))

    figure; 
    hold on
    spectral(X, fs, plotting);  
    spectral(X_filt_notch, fs, plotting); 
    title(participant + " Power Spectrum");
    legend("Notch Filtered", "Filtered");
end

%% Get indices of target onset 
y_start = zeros(size(y));
ind = 1; 
for i = 2:length(y)
    if y(i) ~= y(i-1) && y(i-1) == 0 && y(i) ~= 0
        y_start(i) = 1;
        y_start_ind(ind) = i;  
        ind = ind +1; 
    end
end 
%% Splice, Baseline Correction, Artefact Removal
% Splicing into cell array since that's one of the easier arrays to mess
% with
%We're grabbing the 50 ms before and the 500 ms after any given targulus
%it's possible all we need is the 200-500 ms after 
pre_ms = 200;
post_ms = 800; 
pre_targ_length = round(pre_ms*.001*fs);
post_targ_length = round(post_ms*.001*fs)-1;

t = linspace(0, post_ms, post_targ_length+1);

%X_trial = zeros([sum(y_start), pre_targ_length+post_targ_length+1, 8]);
y_count = 0;
ind = 1; 
for i = 1:sum(y_start) 
    if max(abs(X_filt(y_start_ind(i):y_start_ind(i)+post_targ_length, :))) < 70
        baseline = mean(X_filt(y_start_ind(i)-pre_targ_length:y_start_ind(i), :));
        if i == 800 && plotOn
            hold on 
            plot(t, X_filt(y_start_ind(i):y_start_ind(i)+post_targ_length, 1)); 
            plot(t, X_filt(y_start_ind(i):y_start_ind(i)+post_targ_length, 1)-baseline(1)); 
            legend("Uncorrected", "Corrected");
            title("Baseline Correction for Epochs Example");
            ylabel("Voltage (microvolts)") 
            xlabel("Time (ms)") 
        end
        X_trial(ind, :, :) = X_filt(y_start_ind(i):y_start_ind(i)+post_targ_length, :)-baseline;
        y_trial(ind) = y(y_start_ind(i));
        y_val(ind) = y_targ(y_start_ind(i));
        y_count = y_count+1; 
        ind = ind + 1;
    end 
end 
%% Resampling 
% Takes different time frames from the study and finds the average across 
% Channels and across time
% Uses those as the features for classification 
% To change the time frames, change the number of bins
% Can also use var, if you want the variance set want_var to true
bin_length = 12;
num_bin = (post_targ_length)/bin_length; 
X_bin = zeros([sum(y_count), num_bin, 8]); 
for i = 1:length(X_trial(:, 1, 1)) 
    for j = 1:num_bin
        x = squeeze(X_trial(i, bin_length*(j-1)+1:bin_length*j, :));
        X_bin(i, j, :) = mean(x);
    end
end 

if plotOn 
    figure; 
    t_temp = linspace(0, 800, length(X_bin(1, :, 1)));
    plot(t_temp, X_bin(1, :, 1));  
    title("Resampled Data Example"); 
    ylabel("Voltage (microvolts)") 
    xlabel("Time (ms)") 
end

    
X = X_bin;

%% Save Data
save("Data/paper"+participant, 'X', 'X_trial', 'y_trial', 't', 'fs'); 
