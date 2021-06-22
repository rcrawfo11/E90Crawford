%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%E90: P300 Offline Implementation
%Spring 2021
%Code by Rekha Crawford
%
%Description: 
%Loads data for specified participant number, creates and saves plots
%specified below. Data that it plots is created in the "Classifier" file. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load and unpack data
%Spliced file created in epoch splicing 
clear
close all

participant = '7';
load("Data/splicedA0" + participant); 
%% Plot Averages and Variances

X_targ = squeeze(mean(X_trial(y_trial == 2, :, :), 1)); 
X_targ_var = squeeze(mean(X_trial(y_trial == 2, :, :), 1)); 

figure; 
plot(t, X_targ);
title(participant+" Target Averages"); 
legend
savefig("Figures/"+participant+"targ_Averages")

figure;
plot(t, X_targ_var);
title(participant+" Target Variance"); 
legend
savefig("Figures/"+participant+"targ_Var")

X_not_targ = squeeze(mean(X_trial(y_trial == 1, :, :), 1)); 
X_not_targ_var = squeeze(mean(X_trial(y_trial == 1, :, :), 1)); 

figure; 
plot(t, X_not_targ);
title(participant+" Non-Target Averages"); 
legend
savefig("Figures/"+participant+"Nottarg_Averages")

figure;
plot(t, X_not_targ_var);
title(participant + " Non-targ Variance");
legend
savefig("Figures/"+participant+"Nottarg_Vars")
%% Plot Channels Average and variance separately 
figure;
for i = 1:8
   subplot(4, 2, i); 
   plot(t, X_targ(:, i));
   title("Channel "+ i);
end
suptitle(participant + " Target Trials")
savefig("Figures/"+participant+"targ_Chan_Avg");

figure;
for i = 1:8
   subplot(4, 2, i);
   plot(t, X_not_targ(:, i));
   title("Channel "+ i);
end
suptitle(participant + " Non-Target Trials") 

savefig("Figures/"+participant+"Nottarg_Chan_Avg");
%% Power spectrum 
figure;
for i = 1:8
   subplot(4, 2, i); 
   [spec, f] = spectral(X_targ(:, i), fs, false); 
   plot(f(1:length(f)/4), spec(1:length(f)/4));
   title("Channel "+ i);
end
suptitle(participant + " Target Trials Power Spectrum")
savefig("Figures/"+participant+"targ_Power_Chan");

figure;
for i = 1:8
   subplot(4, 2, i);
   [spec_not, f] = spectral(X_not_targ(:, i), fs, false); 
   plot(f(1:length(f)/4), spec_not(1:length(f)/4));
   title("Channel "+ i);
end
suptitle(participant + " Non-Target Trials Power Spectrum")
savefig("Figures/"+participant+"Nottarg_Power_Chan");