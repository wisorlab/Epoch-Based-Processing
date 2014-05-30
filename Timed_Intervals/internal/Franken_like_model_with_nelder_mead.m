function [Ti,Td,LA,UA,best_error,error_instant,best_S]=Franken_like_model_with_nelder_mead(datafile,signal,filename)
% USAGE:  [Ti,Td,LA,UA,error]=Franken_like_model_with_nelder_mead(datafile,signal)
%
% datafile: a sleep data file from Jonathan Wisor where sleep
%           state is in the first column, lactate or EEG data in the second column 
%
% signal: either 'delta' or 'lactate' 
%
% OUTPUT:
% Ti: the optimum value for tau_i, the rate of increase, using a
% two-process-like model, similar to Franken et al 2001
%
% Td: the optimum value for tau_d, the decay rate. 
% 
% error: the mean square error for the best fit
tic


window_length=4;  % size of moving window (in hours) used to compute
                  % the upper and lower asymptotes for the S model.  


% make a frequency plot, and use it to figure out upper and lower
% bounds for the model (like Franken et al. 2001 Figure 1)

[LA,UA]=make_frequency_plot(datafile,window_length,signal);

% if using delta power as a signal, prepare the data we will compare 
% to by finding all SWS episodes of longer than 5 minutes (like 
% Franken et al)
if strcmp(signal,'delta1') | strcmp(signal,'delta2')
  [t_mdpt_SWS,data_at_SWS_midpoints,t_mdpt_indices]=find_all_SWS_episodes2(datafile);
end

% if using a moving window for the upper and lower assymptotes, S
% will have 720 fewer elements than the number of rows of datafile,
% so set up a new index for S
% mask=find(t_mdpt_indices>360 & t_mdpt_indices<(size(datafile,1)-360));
% t_mdpt_SWS_moving_window=t_mdpt_SWS(mask);
% data_at_SWS_midpoints_moving_window=data_at_SWS_midpoints(mask);
% t_mdpt_indices_moving_window=t_mdpt_indices(mask);
%mask=361:size(datafile,1)-360';



mask=(window_length/2)*360+1:size(datafile,1)-(window_length/2)*360;


dt=1/360;  % assuming data points are every 10 seconds and t is in hours 
% tau_i=[0.05:0.01:1 1.1:.5:5];  %1:.12:25
% tau_d=[0.05:0.01:1 1.1:.5:5]; %0.1:.025:5
% error=zeros(length(tau_i),length(tau_d));

% COMPUTING LOOP
% use the nelder_mead algorithm to find the global minimum error
% fminsearch uses Nelder-Mead
initial_guess = [1 1];     % one starting guess

if strcmp(signal,'delta1') | strcmp(signal,'delta2')
  [bestparams,best_error] = fminsearch(@(p) myobjectivefunction(signal,t_mdpt_indices,data_at_SWS_midpoints, ...
								datafile,dt,LA,UA,window_length,mask,p), [0.5 1])
end

if strcmp(signal,'lactate')
  [bestparams,best_error] = fminsearch(@(p) myobjectivefunction(signal,0,0,datafile,dt,LA,UA, ...
								window_length,mask,p), [0.5 1]);
end
best_tau_i=bestparams(1);
best_tau_d=bestparams(2);

Ti=best_tau_i;    %output the best taus
Td=best_tau_d;


% run one more time with best fit and plot it (add a plot with circles)
if  strcmp(signal,'lactate')
  best_S=run_S_model(datafile,dt,(LA(1)+UA(1))/2,LA,UA,Ti,Td,window_length,1,filename);
  %error_instant=run_instant_model(datafile,LA,UA,window_length);
error_instant = 0;
end
if strcmp(signal,'delta1') | strcmp(signal,'delta2')
 best_S=run_S_model(datafile,dt,(LA(1)+UA(1))/2,LA,UA,Ti,Td,window_length,0,filename);
end


t=0:dt:dt*(size(datafile,1)-1);


if strcmp(signal,'delta1') | strcmp(signal,'delta2') 
  error_instant=0;  % this won't get set if signal is delta, but the function returns it
  figure
  %only_sleep_indices=find(datafile(:,1)==1);  
  %sleep_eeg1=datafile(only_sleep_indices,3);
  %sleep_eeg2=datafile(only_sleep_indices,4);
  %scatter(t(only_sleep_indices),sleep_eeg2,25,'r')
  plot(t_mdpt_SWS,data_at_SWS_midpoints,'go')
  hold on
  plot(t,best_S)
  ylabel('Delta power')
  xlabel('Time (hours)')
  title(['Best fit of model to delta power data for file ' filename])
    hold off


  elseif strcmp(signal,'lactate')
    figure
    plot(t,datafile(:,2),'ro')
  
    hold on
   %tS=t(361:end-360);
    tS=t((window_length/2)*360+1:end-(window_length/2)*360);
    plot(tS,best_S)
    plot(tS,LA,'k--')
    plot(tS,UA,'k--')
    ylabel('lactate')
    xlabel('Time (hours)')
    title('Best fit of model to lactate data')
    hold off
    
  end

  toc

% hold on

% if strcmp(signal,'delta') 
%   plot(t_mdpt_SWS,data_at_SWS_midpoints,'ro')
% ylabel('Delta power')
% elseif strcmp(signal,'lactate')
%   plot(t,datafile(:,2),'ro')
% ylabel('lactate')
% end

% hold off
% if strcmp(signal,'delta')
%   title('Best fit of model to delta power data')
% elseif strcmp(signal,'lactate')
%   title('Best fit of model to lactate data')
% end  
% xlabel('Time (hours)')



% make a contour plot of the errors
% figure
% [X,Y]=meshgrid(tau_d,tau_i);
% contour(X,Y,error,100)
% ylabel('\tau_i')
% xlabel('\tau_d')
%colorbar


