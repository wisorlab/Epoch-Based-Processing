function [wake_agreement2sec,SWS_agreement2sec,REM_agreement2sec,global_agreement2sec,kappa2sec, ...
	      wake_agreement10sec,SWS_agreement10sec,REM_agreement10sec,global_agreement10sec,kappa10sec] = comparePCAscoreepochlength(signal,twosecdirectory,tensecdirectory)

% usage: comparePCAscoreepochlength(signal,directory)
%
%
% This function calls classify_usingPCA.m on each .txt file in the directory given as the 
% second argument.  It uses principal component analysis (following Gilmour et al Neurosci Letters 2010) to 
% distinguish sleep states and computes the kappa statistic, global agreement, and percentage agreement 
% of each sleep state.  
% The purpose of this function is to compare computer vs. human scoring in 10-second epochs 
% and 2-second epochs. To do a fair comparison between those two epoch lengths, we use
% only 8640 epochs of data.  This corresponds to 24 hours of data in a 10-second 
% epoch file and almost 5 hours of data in a 2-second epoch file. 
%
% This script first reads in the files than removes all of the data except 
% the 8640 epochs starting at the first instance of 10 AM.  


%A boxplot is made summarizing these statistics for all files in this directory.
%
% INPUTS:
% signal:  'EEG1' or 'EEG2'
% twosecdirectory:  where the txt files are kept that are scored in 2 sec epochs  (don't forget the final \)
% tensecdirectory: where the txt files are kept that are scored in 10 sec epochs (don't forget the final \)
%
% TO DO: 
% Make the return arguments cell arrays so I don't have some many different things returned. 
% I could have one cell array for wake agreement. It would have a vector in each entry that contains
% the wake agreement percentage for each dataset, etc. 


% read in 2sec epoch files (being careful not to read in files that have already been scored)
two_sec_directory_plus_extension=strcat(twosecdirectory,'*.txt');
two_sec_files=dir(two_sec_directory_plus_extension);
for i=length(two_sec_files):-1:1                % don't autoscore files that have already been autoscored
	fname = two_sec_files(i).name;
	if strfind(fname,'AUTOSCORED')
		two_sec_files(i)=[];
	end
end

% read in 10sec epoch files (being careful not to read in files that have already been scored)
ten_sec_directory_plus_extension=strcat(tensecdirectory,'*.txt');
ten_sec_files=dir(ten_sec_directory_plus_extension);
for i=length(ten_sec_files):-1:1                % don't autoscore files that have already been autoscored
	fname = ten_sec_files(i).name;
	if strfind(fname,'AUTOSCORED')
		ten_sec_files(i)=[];
	end
end




% call classify_usingPCA.m for each file 
for i=1:length(two_sec_files)
	two_sec_files(i).name
	[predicted_score,kappa2sec(i),global_agreement2sec(i),wake_agreement2sec(i),SWS_agreement2sec(i),REM_agreement2sec(i)] ...
	     =classify_usingPCA(strcat(directory,two_sec_files(i).name),signal,0,1,0);
	clear predicted_score 
end

for i=1:length(ten_sec_files)
	ten_sec_files(i).name
	[predicted_score,kappa10sec(i),global_agreement10sec(i),wake_agreement10sec(i),SWS_agreement10sec(i),REM_agreement10sec(i)] ...
	     =classify_usingPCA(strcat(directory,ten_sec_files(i).name),signal,0,1,0);
	clear predicted_score 
end



figure
boxplot([wake_agreement2sec',SWS_agreement2sec',REM_agreement2sec',global_agreement2sec',kappa2sec', ...
	     wake_agreement10sec',SWS_agreement10sec',REM_agreement10sec',global_agreement10sec',kappa10sec'],'labels', ...
	     {'Wake_2sec', 'SWS_2sec', 'REM_2sec', 'Overall_2sec', 'Kappa_2sec','Wake_10sec', 'SWS_10sec', 'REM_10sec', 'Overall_10sec', 'Kappa_10sec' }, ...
	'plotstyle','compact','boxstyle','filled','colors','rb');
ax=gca();
set(ax,'YGrid','on')
title(directory)