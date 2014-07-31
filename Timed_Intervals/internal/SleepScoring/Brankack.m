%This script tests the idea of Brankack et al to plot the data along 
% the axes of Delta, Gamma2 and EMG or Theta2 to look for clustering
function Brankack(data)
  % it reads in the edf record as constructed in edfread.m


% First compute the spectrogram
  n = size(data.eeg, 2);  %total number of epochs?

% Transform EEG signals to frequency domain
eegN = size(data.eeg, 1);
[~, eegF, ~, eegP] = spectrogram(reshape(data.eeg, 1, n * eegN),eegN, 0.0, 2 ^ nextpow2(eegN), data.eeg_f);

bands = linspace(1,70,139);
input = zeros(n, length(bands));
for i = 1 : length(bands)-1
    input(:, i) = sum(eegP(and(eegF >= bands(i), eegF < bands(i + 1)), :), 1);
end;

delta = sum(input(:,1:6),2);   %1-4 Hz
theta2 = sum(input(:,13:15),2);  %7-8.5 Hz
gamma2 = sum(input(:,103:138),2);   %52-70 Hz


figure
plot3(delta,gamma2,theta2,'.')
xlabel('Delta')
ylabel('Gamma2')
zlabel('Theta2')
title('Following Brankack et al.')