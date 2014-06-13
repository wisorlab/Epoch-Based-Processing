% this script makes the following table:
% 
%          tau_i(SEM)   tau_d(SEM)  UA(SEM)  LA(SEM)  running_time  
% SWA NM  
% SWA ES
% Lactate NM 
% Lactate ES


data_dir = 'D:\mrempe\strain_study_data\BL\long_files\'; 

% First call PROCESSLBATCHMODE.m using NM and delta
[signal,state,bestS,UANMdelta,LANMdelta,timerNMdelta,tiNMdelta,tdNMdelta]=PROCESSLBATCHMODE(data_dir,'delta2','NelderMead');

% Now call PROCESSLBATCHMODE.m using brute force and delta
[signal,state,bestS,UABFdelta,LABFdelta,timerBFdelta,tiBFdelta,tdBFdelta]=PROCESSLBATCHMODE(data_dir,'delta2','BruteForce');

% call PROCESSLBATCHMODE.m using brute force and lactate
[signal,state,bestS,UABFlactate,LABFlactate,timerBFlactate,tiBFlactate,tdBFlactate]=PROCESSLBATCHMODE(data_dir,'lactate','BruteForce');

% call  PROCESSLBATCHMODE.m using NM and lactate
[signal,state,bestS,UANMlactate,LANMlactate,timerNMlactate,tiNMlactate,tdNMlactate]=PROCESSLBATCHMODE(data_dir,'lactate','NelderMead');

% now compute averages and SEMs
meantiNMdelta = mean(tiNMdelta);                     % tau values
meantdNMdelta = mean(tdNMdelta);
SEMtiNMdelta  = std(tiNMdelta)/length(tiNMdelta);
SEMtdNMdelta  = std(tdNMdelta)/length(tdNMdelta);

meantiBFdelta = mean(tiBFdelta);
meantdBFdelta = mean(tdBFdelta);
SEMtiBFdelta  = std(tiBFdelta)/length(tiBFdelta);
SEMtdBFdelta  = std(tdBFdelta)/length(tiBFdelta);

meantiBFlactate = mean(tiBFlactate);
meantdBFlactate = mean(tdBFlactate);
SEMtiBFlactate  = std(tiBFlactate)/length(tiBFlactate);
SEMtdBFlactate  = std(tdBFlactate)/length(tdBFlactate);

meantiNMlactate = mean(tiNMlactate);
meantdNMlactate = mean(tdNMlactate);
SEMtiNMlactate  = std(tiNMlactate)/length(tiNMlactate);
SEMtdNMlactate  = std(tdNMlactate)/length(tdNMlactate);

mean



[num2str(mean_ti) '(' num2str(SEM_ti) ')' ...






save table_values.mat   %save it all into a matlab workspace