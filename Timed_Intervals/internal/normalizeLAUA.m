function [LAnormalized,UAnormalized]=normalizeLAUA(LA,UA,datafile,TimeStampMatrix)
%
% Usage: [LAnorm,UAnorm]=normalizeLAUA(LA,UA)
%
% This function normalizes the upper and lower asymptotes 
% for the Process S model and normalizes them to the mean SWS delta 
% power in last 4 hours of the baseline light period (1-5PM)
%
% INPUTS: 
% LA:       scalar (SWA) or vector (lactate) of the lower asymptote
% UA:       scalar (SWA) or vector (lactate) of the upper asymptote
% TimeStampMatrix:  A matrix with as many columns as epochs. Each column
%                   contains a string with the month,day,year,hour,minute,second 
  



% Find the first instance of 1PM in the data
onePMlocs = find(TimeStampMatrix(4,:)==13 & TimeStampMatrix(5,:)==0 & TimeStampMatrix(6,:)==0); %13:00, 1:00PM
ind_start = onePMlocs(1);

% Find first instance of 5PM that comes after the first instance of 1PM
fivePMlocs = find(TimeStampMatrix(4,:)==17 & TimeStampMatrix(5,:)==0 & TimeStampMatrix(6,:)==0); %17:00, 5:00PM
a=find(fivePMlocs>ind_start);    % only keep those that occur after ind_start
if numel(a)==0
	ind_end = size(TimeStampMatrix,2);  % if the file is too short and does not reach 5:00PM after the first 1:00PM
else
	ind_end = fivePMlocs(a(1));
end

  epochs_in_4_hrs = ind_end-ind_start;
  % baseline_start_hours = 17;   % These values are only good if the dataset starts at 8:00 PM
  % baseline_end_hours = 21;
  % ind_start = baseline_start_hours*(60*60/epoch_length);
  % ind_end = baseline_end_hours*(60*60/epoch_length);
  
  if length(datafile)<ind_end     % if the file is too short
  	locs = find(datafile(end-epochs_in_4_hrs:end,1)==1);
  	mn = mean(datafile(end-epochs_in_4_hrs+locs-1,2));
  else
    locs = find(datafile(ind_start:ind_end,1)==1); % find SWS epochs in last 4 hr of baseline
    mn   = mean(datafile(locs+ind_start-1,2));     % mean delta power during SWS in last 4hr of baseline
  end
  LAnormalized = (LA/mn)*100;   % lower asymptote normalized to mean delta power during SWS in last 4hr of baseline
  UAnormalized = (UA/mn)*100;   % upper asymptote normalized to mean delta power during SWS in last 4hr of baseline