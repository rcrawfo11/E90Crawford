%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Using https://medium.com/impulse-neiry/simple-p300-classifier-on-open-data-27e906f68b83
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load and unpack data
clear
load preprocessed 
%% Trial Averages 
epoch_length = 0.9*fs;

for i = 1:length(trial)
    X_trial{i} = X_scale(trial(i):trial(i)+epoch_length, :);
    y_trial(i) = y_down(trial(i)+1);
end 


t = linspace(0, 900, epoch_length+1);

%% Get Raw Plots of EEG Data for the first 5 stimulus showings
titles = ["Fz","Cz","Pz","Oz","P3","P4","PO7","PO8"];

figure()
for i=1:8
    subplot(8,1,i)
    plot(t, X_trial{2}(:,i))
    title(titles(i))
    xlabel("t (ms)")
end

%% Averaging To show X_P300 Spike
X_target = X_trial(y_trial == 2); 
X_non = X_trial(y_trial == 1); 

X_target_mean = cellfun(@(x) mean(x, 2), X_target, 'UniformOutput', false);
X_non_mean = cellfun(@(x) mean(x, 2), X_non, 'UniformOutput', false);

X_tm = reshape(cell2mat(X_target_mean), [11 116]);
X_nm = reshape(cell2mat(X_non_mean), [24 116]); 
X_tm_std = std(X_tm); 
X_nm_std = std(X_nm); 
X_tm = mean(X_tm);
X_nm = mean(X_nm); 

close
figure() 
hold on
plot(t(:), X_tm(:))
plot(t(:), X_nm(:))
legend('target', 'non-target');

