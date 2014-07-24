function [wake_agreement,SWS_agreement,REM_agreement,global_agreement,kappa]=TESTPCASCOREBATCHMODE(signal,directory)

% usage: TESTPCASCOREBATCHMODE(signal,directory)
%
% signal:  'EEG1' or 'EEG2'
% directory:  where the txt files are kept  (don't forget the final \)
%

directory_plus_extension=strcat(directory,'*.txt');
files=dir(directory_plus_extension);

for i=1:length(files)
	files(i).name
	[predicted_score,kappa(i),global_agreement(i),wake_agreement(i),SWS_agreement(i),REM_agreement(i)]=classify_usingPCA(strcat(directory,files(i).name),signal);
	
clear predicted_score 
end


figure
boxplot([wake_agreement',SWS_agreement',REM_agreement',global_agreement',kappa'],'labels',{'Wake', 'SWS', 'REM', 'Overall', 'Kappa'}, ...
	'plotstyle','compact','boxstyle','filled','colors','rb');
ax=gca();
set(ax,'YGrid','on')
title(directory)