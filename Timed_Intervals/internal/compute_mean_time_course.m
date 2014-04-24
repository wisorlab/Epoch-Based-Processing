function [signal_mean,SEM_data,tdata,meanS,SEM_S,tS]=compute_mean_time_course(path,signal)%signal_data,best_S)
%USAGE:  [signal_mean,SEM_data,tdata,meanS,SEM_S,tS]=compute_mean_time_course(path,signal)
%
%
% This function is used by shaded_figure_script.m. It does some of the un-sexy
% computing of things like normalizing the data, averaging over all animals in a strain,
% and computing the SEM.
% 
% Including more substantial and useful comments here. 




% First call PROCESSLBATCHMODE.m  so we can get the raw data (either lactate or delta),
% as well as the best fit of the model S to the data. 
[signal_data,best_S,Taui,Taud]=PROCESSLBATCHMODE(path,signal);
N=length(signal_data);  % # of data files


% Normalize each delta power trace to the individual mean delta power
% in SWS over the last 4 hours of the baseline light period. (for each animal)
baseline_start_hours = 20;
baseline_end_hours = 24;
ind_start = baseline_start_hours*360;
ind_end = baseline_end_hours*360;
figure
for i=1:N
  if(length(signal_data{i})>ind_end) % exclude files that are too short
    mn = mean(signal_data{i}(ind_start:ind_end)); 
    normalized{i} = (signal_data{i}/mn)*100;  %100 is so plot is in percent
  plot(normalized{i})
pause
  end
end



% Average delta power over consecutive 45 minute intervals (for each animal)
for i=1:N
  intervals = floor(length(normalized{i})/270);  
  r = reshape(normalized{i}(1:270*intervals),270,intervals);
  Average_delta{i} = mean(r',2);  %fast way to compute average
end


 
% Now average over all animals in this strain 
[maxsize,maxind]=max(cellfun('length',Average_delta)) % compute the size of longest dataset (in epochs)

for i=1:N   
  for j=1:maxsize
    if length(Average_delta{i})<j
      temp(i,j) = NaN;
    else
      temp(i,j) = Average_delta{i}(j);
    end
    
  end 
end

signal_mean = nanmean(temp,1);


% Compute the SEM over all animals in this strain
SEM_data = nansem(temp);

tdata=.75:.75:maxsize*.75; % time in hours at which we have data (.75 hours=45 minutes)

% ----------------------------------------------------------------------------------
% Repeat everything above for S:
%  Normalize each S to individual mean delta power in SWS over last 4 hr of baseline
figure
for i=1:N
  if(length(best_S{i})>ind_end) %exclude files that are too short
    mn = mean(best_S{i}(ind_start:ind_end)); 
    normalizedS{i} = (best_S{i}/mn)*100;  %100 is so plot is in percent
  plot(normalizedS{i})
pause
  end
end

% Average 15 MINUTE mean values of Process S for each animal
for i=1:N
  intervals = floor(length(normalizedS{i})/90);  
  r = reshape(normalizedS{i}(1:90*intervals),90,intervals);
  Average_S{i} = mean(r',2);  %fast way to compute average
end


% average over all animals in this strain
[maxsizeS,maxindS]=max(cellfun('length',Average_S)) % compute the size of longest dataset (in epochs)
for i=1:N   
  for j=1:maxsizeS
    if length(Average_S{i})<j
      tempS(i,j) = NaN;
    else
      tempS(i,j) = Average_S{i}(j);
    end
    
  end 
end

meanS = nanmean(tempS,1);

% Compute the SEM over all animals in this strain
SEM_S = nansem(tempS);

% Set up t_S vector for this group?  (shortest of files in group?)
tS=.25:.25:maxsizeS*.25;

