function [power, f] = spectral(input, fs, plotting)
%Spectral: Gets and plots the power spectral density of a signal
%   Parameters: 
%   input - time signal
%   fs - sampling frequency 
%   plotting - boolean that specifies whether or not to plot spectral
%   density
%
%   Outputs: 
%   power - power spectral density of signal
%   f - frequencies of power spectral density 
y = fft(input);
n = length(input);          % number of samples
f = (0:n-1)*(fs/n);     % frequency range
power = abs(y).^2/n;    % power of the DFT
no_dup = round(length(f)/2); 
if plotting
    plot(f(1:no_dup),10*log10(power(1:no_dup)))
    xlabel('Frequency') 
    ylabel('Power')
end
end

