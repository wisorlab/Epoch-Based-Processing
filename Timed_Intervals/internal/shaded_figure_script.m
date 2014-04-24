% This script makes a figure analogous to Figure 2 in Franken et al 2001. 

% signal: 'lactate', 'delta1', or 'delta2'
signal = 'delta1';


%These are the paths where the data are stored:
AKR_path = 'D:/mrempe/strain_study_data/AKR/long_files/concat/';
BA_path  = 'D:/mrempe/strain_study_data/BA/BA_long/';
BL_path  = 'D:/mrempe/strain_study_data/BL/long_files/';
DBA_path = 'D:/mrempe/strain_study_data/DBA/long_files/';



% Get the data to plot using compute_mean_time_course.m
[deltapower_meanAKR,SEM_deltaAKR,t_deltaAKR,meanS_AKR,SEM_S_AKR,tS_AKR] = compute_mean_time_course(AKR_path,signal);
[deltapower_meanBA,SEM_deltaBA,t_deltaBA,meanS_BA,SEM_S_BA,tS_BA]       = compute_mean_time_course(BA_path,signal);
[deltapower_meanBL,SEM_deltaBL,t_deltaBL,meanS_BL,SEM_S_BL,tS_BL]       = compute_mean_time_course(BL_path,signal);
[deltapower_meanDBA,SEM_deltaDBA,t_deltaDBA,meanS_DBA,SEM_S_DBA,tS_DBA] = compute_mean_time_course(DBA_path,signal);


% Now make the figure
figure

subplot(4,1,1)  %AKR
h=errorbar(t_deltaAKR,deltapower_meanAKR,SEM_deltaAKR,'k.')
errorbar_tick(h,0)
hold on
fill_between_lines(tS_AKR,meanS_AKR+SEM_S_AKR,meanS_AKR-SEM_S_AKR,[0.5 0.5 0.5])
hold off

subplot(4,1,2)  %BA
h=errorbar(t_deltaBA,deltapower_meanBA,SEM_deltaBA,'k.')
errorbar_tick(h,0)
hold on
fill_between_lines(tS_BA,meanS_BA+SEM_S_BA,meanS_BA-SEM_S_BA,[0.5 0.5 0.5])
hold off

subplot(4,1,3)  %BL
h=errorbar(t_deltaBL,deltapower_meanBL,SEM_deltaBL,'k.')
errorbar_tick(h,0)
hold on
fill_between_lines(tS_BL,meanS_BL+SEM_S_BL,meanS_BL-SEM_S_BL,[0.5 0.5 0.5])
hold off

subplot(4,1,4)  %DBA
h=errorbar(t_deltaDBA,deltapower_meanDBA,SEM_deltaDBA,'k.')
errorbar_tick(h,0)
hold on
fill_between_lines(tS_DBA,meanS_DBA+SEM_S_DBA,meanS_DBA-SEM_S_DBA,[0.5 0.5 0.5])
hold off




