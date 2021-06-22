%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Using this resource: https://medium.com/impulse-neiry/simple-p300-classifier-on-open-data-27e906f68b83
% Consists of: 
% Decimation (down-sampling) 
% Filtering 
% Scaling
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Unpack Data 
% Turn this into a function later
clear
close 

participant = "A01";
load("Data/"+participant)
plotOn = false; 
[X, y, y_stim, trial, classes, classes_stim] = unpackData(data);
fs = 256; 
%% Filtering 
% Filter with a 0.5 Hz - 20 Hz Bandpass filter and notch
Wn = [0.5 10]/(fs/2);
[b, a] = butter(4, Wn, 'bandpass');
plotting = true;

X_filt = filtfilt(b, a, X);

if plotOn
close all;
figure;
hold on
plot(X_filt(1:100, 1))
plot(X(1:100, 1))

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
legend("Unfiltered", "Filtered");
end
%% Decimation
% Downsample by a factor of 2 

downSamp = 2;
fs = 256/downSamp;

for i = 1:length(X(1, :))
    X_down(:, i) = decimate(X_filt_notch(:,i), downSamp); 
end
y_down = y(1:downSamp:end); 
y_stim_down= y_stim(1:downSamp:end);

trial = round(trial/downSamp)+1;

%Plotting
if plotOn
subplot(2, 1, 1);
plot(X(1:256, 1)); 

subplot(2, 1, 2)
plot(X_down(1:fs, 1))
end

%% Artifact Removal 

%% Scaling 
% Seems like just subtracts mean and divides by STD, channelwise

for i = 1:length(X(1, :))
    X_scale(:, i) = (X_down(:, i) - mean(X_down(:, i)))/std(X_down(:,i));
end

if plotOn
    close;
    figure;
    hold on
    plot(X_down(1:100, 1))
    plot(X_scale(1:100, 1))
    
    figure();
    subplot(2, 1, 1);
    plot(X_down(1:fs, 1)); 
    subplot(2, 1, 2)
    plot(X_scale(1:fs, 1))
end


%% Save data

save('Data/preprocessed'+participant, 'X_scale', 'y_down', 'y_stim_down', 'trial', 'fs', 'participant');