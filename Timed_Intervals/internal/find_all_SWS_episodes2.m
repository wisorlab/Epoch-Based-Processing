function [t_mdpt_SWS,data_at_SWS_midpoints,t_mdpt_indices]=find_all_SWS_episodes2(datafile,signal)
%USAGE:
% [t_mdpt_SWS,t_midpt_indices,data_at_SWS_midpoints]=find_all_SWS_episodes2(datafile,signal)
% 
% This function finds all the episodes of length 5 minutes
% in which SWA makes up at least 90% of the activity in those 5 minutes
% and computes the median delta power (or lactate) in each of these SWS episodes
% and the time of episode midpoint. Similar but different from Franken et al. 2001
% Figure 1.  
%
% INPUTS: 
% datafile:    This is a data file containing 4 columns, where
%          sleep state is in the first column (0=wake,1=SWS,2=REM), lactate
%          is in the second column, average delta power in EEG1 is in the 
%          third column, and averge delta power in EEG2 is in the 4th column.
%
%          if datafile has only 2 columns that means it has already been processed, 
%          so just keep it.  It has sleep state in first column and delta or lactate in second

% signal: 'lactate' or 'delta1' or 'delta2'
%
% OUTPUTS:
% t_mdpt_SWS:  the times (in hours) of the midpoints of the 5 minute episodes
% in which SWA makes up at least 90% of data. 
%
% data_at_SWS_midpoints:  median delta power or lactate 
%                         signal at the midpoints of SWS episodes
%                         longer than 5 minutes
%
% t_mdpt_indices:  the indices of t (original time vector)
%                  corresponding to the midpoints of the SWS episodes.


% First set up a vector of time in hours
t_hours=0:1/360:(1/360)*(size(datafile,1)-1);  %1/360 because 10 seconds
                                        %is 1/360 of an hour. 


% Pick off the correct data from datafile
if size(datafile,2) > 2 
  if strcmp(signal,'delta1')
    data=datafile(:,3);
  elseif strcmp(signal,'delta2')
    data=datafile(:,4);
  elseif strcmp(signal,'lactate')
    data=datafile(:,2);
  end
else
  data=datafile(:,2);  % in this case, the correct column has already been plucked off
                       % second column has delta or lactate data, first column has sleep state.
 end
size(data)



% initialize
t_mdpt_SWS=0;
data_at_SWS_midpoints=0;
t_mdpt_indices=0;
counter=0;  % counter for number of SWS episodes longer than 5 min.
starting_indices=0;

% for each 5 min sliding window check to see if 90% or more is SWA
for i=30:size(datafile,1)
  if length(find(datafile(i-29:i,1)==1))>=27
    counter = counter+1;
    starting_indices(counter)=i-29;
    % t_mdpt_SWS(counter) = mean([t_hours(i-15),t_hours(i-14)]);
    % data_at_SWS_midpoints(counter) = median(data(i-29:i));
    % t_mdpt_indices(counter)=i-15;
 
  end
end

disp(['5 min windows with 90 percent SWA: ' num2str(counter)])

% now combine overlapping 5 minute windows
first_index_of_streak=1;
streak_counter=1;
while first_index_of_streak < length(starting_indices)
  c = max(find(starting_indices<(30+starting_indices(first_index_of_streak))));

%end_of_streak=starting_indices(c)+30
 
  t_mdpt_SWS(streak_counter) = mean([t_hours(starting_indices(first_index_of_streak)),t_hours(starting_indices(c)+29)]);
  data_at_SWS_midpoints(streak_counter) = median(data(starting_indices(first_index_of_streak):starting_indices(c)+29));
  t_mdpt_indices(streak_counter)=starting_indices(first_index_of_streak)+14;
  first_index_of_streak=c+1;  
  streak_counter=streak_counter+1;  

end





%figure
%plot(t_hours,data,t_mdpt_SWS,data_at_SWS_midpoints,'o')
%plot(t_mdpt_SWS,data_at_SWS_midpoints,'o')
%title('this is just midpoints of SWS episodes, not a model fit')
%xlabel('Time (hours)')
%hold off

% improve this plot to include the sleep state data 
