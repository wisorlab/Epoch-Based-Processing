function [data,textdata]=importdatafile(FileToRead,directory)
% usage: [data,textdata]=importdatafile(FileToRead,directory)

% this function uses textscan to read in a .txt data file
% and convert it to two matrices, one for numeric data and 
% one for text
% textscan is more robust than importdata.m as textscan 
% will not quit like importdata does if there is missing data
%
% Also, I'm adding some code to check for negative lactate values 
% at the end of the file, and to cut off the file before the 
% negative values if they exist.  


%OUTPUTS:
%      data     This is a matrix containing 2 fewer rows than
%               the original .txt file with only the numeric
%               data.  

%      textdata This is a cell array containing the strings in 
%               columns 1 and 2 of the data file (timestamp and sleep state)
%               NOTE1: use curly brackets to access elements in 
%               textdata. i.e. textdata{3,2} for the the sleep state 
%               on line 3.  
%               NOTE2: textdata has already had the first two
%               rows removed.  It is just strings on lines 
%               containing EEG data. 

if nargin ==1 
	directory='';
end


DELIMITER = '\t';
HEADERLINES = 2;
NUM_COLUMNS = 82;  % number of colums in original data set 
                   % minus 2 for the 2 columns of text


filename=strcat(directory,FileToRead);

fid=fopen(filename);

format=['%s%s' repmat('%f', [1 NUM_COLUMNS])];
%format=['%s',repmat('%f',1,NUM_COLUMNS)];
c=textscan(fid,format,'Headerlines',HEADERLINES,'Delimiter',DELIMITER,'CollectOutput',1,'ReturnOnError',0);
textdata=c{1};
data=c{2};
fclose(fid);



% check for negative values in the lactate signal (first
% column of data) at the beginning or the end of 
% the file.  If so, cut off that data

% first find all locations where lactate < 0 and
% remove them from data and textdata
locations=find(data(:,1)<0);
data(locations,:)=[];
textdata(locations,:)=[];

