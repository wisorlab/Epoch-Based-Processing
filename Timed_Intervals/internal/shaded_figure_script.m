% This script makes a figure analogous to Figure 2 in Franken et al 2001. 

% -- Parameters --
% signal: 'lactate', 'delta1', or 'delta2'
signal = 'lactate';

% gap is used for plotting data in the lactate case since you don't want to plot all of it
gap = 45;  %in minutes


%These are the paths where the data are stored:
AKR_path = 'D:/mrempe/strain_study_data/AKR/long_files/concat/';
BA_path  = 'D:/mrempe/strain_study_data/BA/BA_long/';
BL_path  = 'D:/mrempe/strain_study_data/BL/long_files/';
DBA_path = 'D:/mrempe/strain_study_data/DBA/long_files/';



% Get the data to plot using compute_mean_time_course.m
[signal_meanAKR,SEM_signalAKR,t_signalAKR,meanS_AKR,SEM_S_AKR,tS_AKR] = compute_mean_time_course(AKR_path,signal);
[signal_meanBA,SEM_signalBA,t_signalBA,meanS_BA,SEM_S_BA,tS_BA]       = compute_mean_time_course(BA_path,signal);
[signal_meanBL,SEM_signalBL,t_signalBL,meanS_BL,SEM_S_BL,tS_BL]       = compute_mean_time_course(BL_path,signal);
[signal_meanDBA,SEM_signalDBA,t_signalDBA,meanS_DBA,SEM_S_DBA,tS_DBA] = compute_mean_time_course(DBA_path,signal);


% Now make the figure
figure

subplot(4,1,1)  %AKR
fill_between_lines(tS_AKR,meanS_AKR+SEM_S_AKR,meanS_AKR-SEM_S_AKR,[0.5 0.5 0.5])
hold on
if strcmp(signal,'lactate')
  h=errorbar(t_signalAKR(gap*3:gap*6:end),signal_meanAKR(gap*3:gap*6:end),SEM_signalAKR(gap*3:gap*6:end),'k.');
else
  h=errorbar(t_signalAKR,signal_meanAKR,SEM_signalAKR,'k.');
end
errorbar_tick(h,0)
hold off
ylabel('AKR')

subplot(4,1,2)  %BA
fill_between_lines(tS_BA,meanS_BA+SEM_S_BA,meanS_BA-SEM_S_BA,[0.5 0.5 0.5])
hold on
if strcmp(signal,'lactate')
  h=errorbar(t_signalBA(gap*3:gap*6:end),signal_meanBA(gap*3:gap*6:end),SEM_signalBA(gap*3:gap*6:end),'k.');
else
  h=errorbar(t_signalBA,signal_meanBA,SEM_signalBA,'k.');
end
errorbar_tick(h,0)
hold off
ylabel('BA')

subplot(4,1,3)  %BL
fill_between_lines(tS_BL,meanS_BL+SEM_S_BL,meanS_BL-SEM_S_BL,[0.5 0.5 0.5])
hold on
if strcmp(signal,'lactate')
  h=errorbar(t_signalBL(gap*3:gap*6:end),signal_meanBL(gap*3:gap*6:end),SEM_signalBL(gap*3:gap*6:end),'k.');
else
  h=errorbar(t_signalBL,signal_meanBL,SEM_signalBL,'k.');
end
errorbar_tick(h,0)
hold off
ylabel('BL')

subplot(4,1,4)  %DBA
fill_between_lines(tS_DBA,meanS_DBA+SEM_S_DBA,meanS_DBA-SEM_S_DBA,[0.5 0.5 0.5])
hold on
if strcmp(signal,'lactate')
  h=errorbar(t_signalDBA(gap*3:gap*6:end),signal_meanDBA(gap*3:gap*6:end),SEM_signalDBA(gap*3:gap*6:end),'k.');
else
  h=errorbar(t_signalDBA,signal_meanDBA,SEM_signalDBA,'k.');
end
errorbar_tick(h,0)
hold off
ylabel('DBA')




