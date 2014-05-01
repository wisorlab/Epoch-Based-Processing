function S=run_S_model(dataset,dt,S0,LA,UA,ti,td,window_length,makeplot,filename)

%usage: S=run_S_model(dataset,S0,LA,UA,ti,td)
% dataset contains sleep state in the
% first colum (0 for wake, 1 for sleep, 2 for REM), lactate in the
% second column and then EEG data in the columns after that. 
%
% S0: the starting value for S
%
% LA: the value of the lower asymptote (found from
%     make_frequency_plot.m)
%
% UA: the value of the upper asymptote (found from
%     make_frequency_plot.m)
%
% ti: the time constant for the increasing exponential
%
% td: the time constant for the decreasing exponential
%
% window_length: is using lactate as the signal, use a moving
% window of length window_length (in hours) to compute LA and UA.
% they are computed as the 90th and 10th percentile for a 2 hour
% moving window centered at each data point. 
%
% makeplot: 1 if you want to make a plot, 0 if you don't


% this function calculates a simple exponential model, like the one
% in Franken, et al J Neurosci 2001.  S goes up if the mouse is
% awake or in REM sleep and goes down if it is asleep.  
%
% call this with the variables ending in smoothedwithtime. 
%
% If lactate is used as the signal, a moving window of length
% window_length (in hours) is used to compute LA and UA.  This is
% to account for drifting of the signal. 

%makeplot=1;  % flag 

if nargin==9
    filename='';
end

 
exp_rise=exp(-dt/ti);  %compute these once to save time
exp_fall=exp(-dt/td);


% CASE 1: using delta power histogram to choose upper and lower
% assymptotes for the model
if length(LA)==1

  %S=zeros(1,size(dataset,1));  % preallocate for speed
 S(1)=0;
  
  % first run it for 24 hours, and use the ending value as the
  % starting value (like Franken et al 2000 Fig 1c)
  if size(dataset,1) >= 8640 
    iters=8640;
  else
    iters=size(dataset,1);
  end
  
  for i=1:iters-1                 % 8640 10-second intervals=24 hours
     if dataset(i,1)==0 || dataset(i,1)==2 %wake or REM
      S(i+1)=UA-(UA-S(i))*exp_rise;
    elseif(dataset(i,1)==1) %sleep
      S(i+1)=LA+(S(i)-LA)*exp_fall;
    else
      error('I found a sleepstate value that was not 0,1, or 2')
    end
  end
  
  
  % Now start the simulation over, using the last value out of S to be the new 
  % starting value of S
  S(1)=S(end);
 
  
  for i=1:size(dataset,1)-1
    if dataset(i,1)==0 || dataset(i,1)==2 %wake or REM
      S(i+1)=UA-(UA-S(i))*exp_rise;
    elseif(dataset(i,1)==1) %sleep
      S(i+1)=LA+(S(i)-LA)*exp_fall;
    else
      error('I found a sleepstate value that was not 0,1, or 2')
    end
  end
  



% CASE 2: using lactate to choose upper and lower asymptotes. In
% this case we use a moving window, so S is not the same size at
% dataset(:,1). The moving window is 2 hours long, so an hour of
% the data at the beginning is discarded, as well as an hour of
% data at the end.  So S has length length(dataset(:,1))-720. 
elseif length(LA) ~=1
 
  
  %S=zeros(1,size(dataset,1)-720);  % preallocate for speed
  %S(1)=S0;
  
  % if size(dataset,1)>8640    % if there is more than 24 hours of data
  %   for i=1:8640                 % 8640 10-second intervals=24 hours
  %     if dataset(i+360,1)==0 || dataset(i+360,1)==2 %wake or REM
  %       S(i+1)=UA(i)-(UA(i)-S(i))*exp_rise;
  %     elseif(dataset(i+360,1)==1) %sleep
  %       S(i+1)=LA(i)+(S(i)-LA(i))*exp_fall;
  %     else
  %       error('I found a sleepstate value that was not 0,1, or 2')
  %     end
  %   end
  % else
  %   for i=1:1800                 % 1800 10-second intervals=5 hours
  %     if dataset(i+360,1)==0 || dataset(i+360,1)==2 %wake or REM
  %       S(i+1)=UA(i)-(UA(i)-S(i))*exp_rise;
  %     elseif(dataset(i+360,1)==1) %sleep
  %       S(i+1)=LA(i)+(S(i)-LA(i))*exp_fall;
  %     else
  %       error('I found a sleepstate value that was not 0,1, or 2')
  %     end
  %   end
  % end
  
  % Now start the simulation over
  %S(1)=S(end);
   %S(1)=dataset(360,2);  % initialize S to lactate value 
S(1)=dataset((window_length/2)*360,2); 
  
  %for i=1:size(dataset,1)-721
for i=1:size(dataset,1)-(window_length*360+1)
  if dataset(i+(window_length/2)*360,1)==0 || dataset(i+(window_length/2)*360,1)==2 %wake or REM
    S(i+1)=UA(i)-(UA(i)-S(i))*exp(-dt/ti);
  elseif(dataset(i+(window_length/2)*360,1)==1) %sleep
    S(i+1)=LA(i)+(S(i)-LA(i))*exp(-dt/td);
  else
    error('I found a sleepstate value that was not 0,1, or 2')
  end
end
  
end %cases: delta power or lactate used for asymptotes

 
if makeplot==1
  
  figure
  t=0:dt:dt*(size(dataset,1)-1);
  %tS=t(361:end-360);
  tS=t((window_length/2)*360+1:end-(window_length/2)*360);

  
  
  if length(LA) ~= 1  
  t=0:dt:dt*(size(dataset,1)-1);
				%plot(t(1),dataset(1,2),'ro')
				%hold on
				% for i=1:length(t)
    %   if(dataset(i,1)==0)
    %     plot(t(i),dataset(i,2),'ro')
    %   elseif(dataset(i,1)==1)
    %     plot(t(i),dataset(i,2),'ko')
    %   elseif(dataset(i,1)==2)
    %     plot(t(i),dataset(i,2),'co')
    %   end
    % end
    
  only_sleep_indices=find(dataset(:,1)==1);
  only_wake_indices=find(dataset(:,1)==0);
  only_rem_indices=find(dataset(:,1)==2);
  sleep_lactate=dataset(only_sleep_indices,2);
  wake_lactate=dataset(only_wake_indices,2);
  rem_lactate=dataset(only_rem_indices,2);

 
    scatter(t(only_wake_indices),wake_lactate,25,'r')
  
    hold on
    scatter(t(only_sleep_indices),sleep_lactate,25,'k')
    scatter(t(only_rem_indices),rem_lactate,25,'c')
    plot(tS,S) 
    
  else 
    
    plot(t,S)
  end
  title(['best fit for file ' filename])
    xlabel('TIME [h]')
    legend('wake','sleep','rem','best fit model')
    legend BOXOFF
    
    hold off
  end


