% this script calls sleepscorePCA.m for each file in the current directory

directory = 'D:\mrempe\strain_study_data\DBA\long_files\'
addpath ..

directory_plus_extension=strcat(directory,'*.txt');
files = dir(directory_plus_extension);     % returns a cell array containing the name, date, bytes and date-as-number for each txt file in this directory.
HowManyFiles = length(files)

for FileCounter=1:length(files)  %this loop imports the data files one-by-one and calls sleepscorePCA.m to perform Principal Component Analysis on each one.   
	clear Feature PCAvectors  % I just want to see the plots, not keep the variables
	[Feature,PCAvectors]=sleepscorePCA(strcat(directory,files(FileCounter).name),'EEG2','PCAoutput.txt');
  
end





