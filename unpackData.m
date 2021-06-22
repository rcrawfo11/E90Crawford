function [X, y, y_stim, trial, classes, classes_stim] = unpackData(data)
%unpackData: Takes in data from paper and unpacks it
%
% Parameters:
% data - struct data from loaded participant file
%
% Output: 
% X - EEG data
% y - label for whether a letter is being shown (0 = not, 1 = shown but
% non-target, 2 = shown and target) 
% y_stim - label for where letter is being shown (numbers correspond to
% place in matrix) 
% trial - indecies of trial onset 
% classes - class labels for y data
% classes_targ - class labels for y_stim data

X = data.X;
y = data.y; 
y_stim = data.y_stim; 
trial = data.trial; 
classes = data.classes; 
classes_stim = data.classes_stim; 
end

