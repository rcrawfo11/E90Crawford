%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Using https://medium.com/impulse-neiry/simple-p300-classifier-on-open-data-27e906f68b83
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Load and unpack data

load A01 

[X, y, y_stim, trial, classes, classes_stim] = unpackData(data); 

%% Trial Averages 
X_trial= cell([length(trial), 1]);
for i = 1:length(trial)
    X_trial{i} = X(trial(i):trial(i)+500, :);
    y_trial(i) = y(trial(i));
end

t = linspace(0, 1953, 501);
%plot(t, X_trial{1}(:, 1))



%X_target = X_mean(;

%plot(t, X_target{3})

%% Get Raw Plots of EEG Data for the first 5 stimulus showings
titles = ["Fz","Cz","Pz","Oz","P3","P4","PO7","PO8"];

figure()
for i=1:8
    subplot(8,1,i)
    plot(t, X_trial{1}(:,i))
    title(titles(i))
    xlabel("t (ms)")
end

%% Averaging To show X_P300 Spike
X_target = X_trial(y_trial == 2); 
X_non = X_trial(y_trial == 1); 

X_target_mean = cellfun(@(x) mean(x, 2), X_target, 'UniformOutput', false);
X_non_mean = cellfun(@(x) mean(x, 2), X_non, 'UniformOutput', false);

X_tm = mean(reshape(cell2mat(X_target_mean), [11 501]));
X_nm = mean(reshape(cell2mat(X_non_mean), [24 501])); 


figure() 
hold on
plot(t(1:100), X_tm(1:100))
plot(t(1:100), X_nm(1:100))


