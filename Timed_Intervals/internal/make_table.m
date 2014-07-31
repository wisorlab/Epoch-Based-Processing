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
meanUANMdelta = mean(cell2mat(UANMdelta));    
meanLANMdelta = mean(cell2mat(LANMdelta));
SEMUANMdelta  = std(cell2mat(UANMdelta))/length(UANMdelta);
SEMLANMdelta  = std(cell2mat(LANMdelta))/length(LANMdelta);

meanUABFdelta = mean(cell2mat(UABFdelta));
meanLABFdelta = mean(cell2mat(LABFdelta));
SEMUABFdelta  = std(cell2mat(UABFdelta))/length(UABFdelta);
SEMLABFdelta  = std(cell2mat(LABFdelta))/length(LABFdelta);

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

Table = [sprintf('%1.2f',meantiNMdelta) '(' sprintf('%1.2f',SEMtiNMdelta) ')  ' ... %ti
	 sprintf('%1.2f',meantdNMdelta) '(' sprintf('%1.2f',SEMtdNMdelta) ')  ' ... %td
	 sprintf('%3.0f',meanUANMdelta) '(' sprintf('%03.0f',SEMUANMdelta) ')  ' ... %UA
	 sprintf('%3.0f',meanLANMdelta) '(' sprintf('%03.0f',SEMLANMdelta) ')  ' ... %LA
	 sprintf('%010.2f',meantimeNMdelta) '(' sprintf('%1.2f',SEMtimeNMdelta) ')'; ...  %running time
	 sprintf('%1.2f',meantiBFdelta) '(' sprintf('%1.2f',SEMtiBFdelta) ')  ' ... %ti
	 sprintf('%1.2f',meantdBFdelta) '(' sprintf('%1.2f',SEMtdBFdelta) ')  ' ... %td
	 sprintf('%3.0f',meanUABFdelta) '(' sprintf('%03.0f',SEMUABFdelta) ')  ' ... %UA
	 sprintf('%3.0f',meanLABFdelta) '(' sprintf('%03.0f',SEMLABFdelta) ')  ' ... %LA
	 sprintf('%010.2f',meantimeBFdelta) '(' sprintf('%1.2f',SEMtimeBFdelta) ')'; ...  %running time
	 sprintf('%1.2f',meantiNMlactate) '(' sprintf('%1.2f',SEMtiNMlactate) ')  ' ... %ti LACTATE
	 sprintf('%1.2f',meantdNMlactate) '(' sprintf('%1.2f',SEMtdNMlactate) ')  ' ... %td
	 sprintf('%3.0f',meanUANMdelta) '(' sprintf('%03.0f',SEMUANMdelta) ')  ' ... %UA
	 sprintf('%3.0f',meanLANMdelta) '(' sprintf('%03.0f',SEMLANMdelta) ')  ' ... %LA
	 sprintf('%010.2f',meantimeNMlactate) '(' sprintf('%1.2f',SEMtimeNMlactate) ')'; ...  %running time
	 sprintf('%1.2f',meantiBFlactate) '(' sprintf('%1.2f',SEMtiBFlactate) ')  ' ... %ti
	 sprintf('%1.2f',meantdBFlactate) '(' sprintf('%1.2f',SEMtdBFlactate) ')  ' ... %td
	 sprintf('%3.0f',meanUABFdelta) '(' sprintf('%03.0f',SEMUABFdelta) ')  ' ... %UA
	 sprintf('%3.0f',meanLABFdelta) '(' sprintf('%03.0f',SEMLABFdelta) ')  ' ... %LA
	 sprintf('%010.2f',meantimeBFlactate) '(' sprintf('%1.2f',SEMtimeBFlactate) ')'];  %running time


save table_values.mat   %save it all into a matlab workspace