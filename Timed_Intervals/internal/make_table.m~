% this script makes the following table:
% 
%          tau_i(SEM)   tau_d(SEM)  UA(SEM)  LA(SEM)  running_time  
% SWA NM  
% SWA ES
% Lactate NM 
% Lactate ES


data_dir = 'D:\mrempe\strain_study_data\BL\fig1_file\'; 

% First call PROCESSLBATCHMODE.m using NM and delta
[signal,state,bestS,UANMdelta,LANMdelta,timerNMdelta,tiNMdelta,tdNMdelta]=PROCESSLBATCHMODE(data_dir,'delta2','NelderMead');

% Now call PROCESSLBATCHMODE.m using brute force and delta
[signal,state,bestS,UABFdelta,LABFdelta,timerBFdelta,tiBFdelta,tdBFdelta]=PROCESSLBATCHMODE(data_dir,'delta2','BruteForce');

% call PROCESSLBATCHMODE.m using brute force and lactate
[signal,state,bestS,UABFlactate,LABFlactate,timerBFlactate,tiBFlactate,tdBFlactate]=PROCESSLBATCHMODE(data_dir,'lactate','BruteForce');

% call  PROCESSLBATCHMODE.m using NM and lactate
[signal,state,bestS,UANMlactate,LANMlactate,timerNMlactate,tiNMlactate,tdNMlactate]=PROCESSLBATCHMODE(data_dir,'lactate','NelderMead');


save table_values.mat   %save it all into a matlab workspace (after all calls to PROCESSLBATCHMODE.m before post-processing)

% now compute averages and SEMs
% tau values
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

% UA and LA
meanUANMdelta = mean(UANMdelta);    
meanLANMdelta = mean(LANMdelta);
SEMUANMdelta  = std(UANMdelta)/length(UANMdelta);
SEMLANMdelta  = std(LANMdelta)/length(LANMdelta);

meanUABFdelta = mean(UABFdelta);
meanLABFdelta = mean(LABFdelta);
SEMUABFdelta  = std(UABFdelta)/length(UABFdelta);
SEMLABFdelta  = std(LABFdelta)/length(LABFdelta);

% computing times
meantimeNMdelta = mean(timerNMdelta);  %delta
SEMtimeNMdelta  = std(timerNMdelta)/length(timerNMdelta);

meantimeBFdelta = mean(timerBFdelta);
SEMtimeBFdelta = std(timerBFdelta)/length(timerBFdelta);

meantimeNMlactate = mean(timerNMlactate);  %lactate
SEMtimeNMlactate  = std(timerNMlactate)/length(timerNMlactate);

meantimeBFlactate = mean(timerBFlactate);
SEMtimeBFlactate = std(timerBFlactate)/length(timerBFlactate);


% Finally, put it all into a matrix 

Table = [num2str(meantiNMdelta,2) '(' num2str(SEMtiNMdelta,2) ')  ' ... %ti
	 num2str(meantdNMdelta,2) '(' num2str(SEMtdNMdelta,2) ')  ' ... %td
	 num2str(meanUANMdelta,2) '(' num2str(SEMUANMdelta,2) ')  ' ... %UA
	 num2str(meanLANMdelta,2) '(' num2str(SEMLANMdelta,2) ')  ' ... %LA
	 num2str(meantimeNMdelta,4) '(' num2str(SEMtimeNMdelta,4) ')  '; ...  %running time
	 num2str(meantiBFdelta,2) '(' num2str(SEMtiBFdelta,2) ')  ' ... %ti
	 num2str(meantdBFdelta,2) '(' num2str(SEMtdBFdelta,2) ')  ' ... %td
	 num2str(meanUABFdelta,2) '(' num2str(SEMUABFdelta,2) ')  ' ... %UA
	 num2str(meanLABFdelta,2) '(' num2str(SEMLABFdelta,2) ')  ' ... %LA
	 num2str(meantimeBFdelta,4) '(' num2str(SEMtimeBFdelta,4) ')  '; ...  %running time
	 num2str(meantiNMlactate,2) '(' num2str(SEMtiNMlactate,2) ')  ' ... %ti LACTATE
	 num2str(meantdNMlactate,2) '(' num2str(SEMtdNMlactate,2) ')  ' ... %td
	 num2str(meanUANMdelta,2) '(' num2str(SEMUANMdelta) ')  ' ... %UA
	 num2str(meanLANMdelta,2) '(' num2str(SEMLANMdelta,2) ')  ' ... %LA
	 num2str(meantimeNMlactate,2) '(' num2str(SEMtimeNMlactate,2) ')  '; ...  %running time
	 num2str(meantiBFlactate,2) '(' num2str(SEMtiBFlactate,2) ')  ' ... %ti
	 num2str(meantdBFlactate,2) '(' num2str(SEMtdBFlactate,2) ')  ' ... %td
	 num2str(meanUABFdelta,2) '(' num2str(SEMUABFdelta,2) ')  ' ... %UA
	 num2str(meanLABFdelta,2) '(' num2str(SEMLABFdelta,2) ')  ' ... %LA
	 num2str(meantimeBFlactate,4) '(' num2str(SEMtimeBFlactate,4) ')  '];  %running time


save table_values.mat   %save it all into a matlab workspace