function error_simple_model=run_instant_model(dataset,LA,UA,window_length)

%usage: error=run_instant_model(dataset,S0,LA,UA)
%
% This function attempts to fit the lactate data
% using only three pieces of information: 
% the sleep state, the value of LA, and the 
% value of UA.  Instead of exponentially 
% approaching the assymptotes, this model 
% instantly goes between the two thresholds. 
% If sleep state is wake or REM, it follows
% UA.  If sleep state is sleep, it follows LA.

%S=zeros(1,size(dataset,1));

for i=1:size(dataset,1)-(window_length*360)
  if dataset(i+(window_length/2)*360,1)==0 || dataset(i+(window_length/2)*360,1)==2 %wake or REM
    S(i)=UA(i);
  elseif(dataset(i+(window_length/2)*360,1)==1) %sleep
    S(i)=LA(i);
  end
end

% make a plot of the stupid model compared to data
 dt=1/360;
  figure
  t=0:dt:dt*(size(dataset,1)-1);
  %tS=t(361:end-360);
  tS=t((window_length/2)*360+1:end-(window_length/2)*360);

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
size(tS)
size(S)
   
 plot(tS,S) 
    xlabel('time (hours)')
    legend('wake','sleep','rem','stupid model')
    hold off

mask=(window_length/2)*360+1:size(dataset,1)-(window_length/2)*360;
error_simple_model=sqrt((sum((S'-dataset([mask],2)).^2))/(size(dataset,1)-(window_length*360)));