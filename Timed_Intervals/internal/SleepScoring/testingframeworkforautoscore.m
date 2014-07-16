% testing framework for autoscore approach

% this script/function should:

% read in an edf file that has a corresponding .txt file in the same directory?  
% Start with BA120540 edf and txt

% - call edfread.m to get header and records
% - set up a vector of time stamps for the data in records
% - cut off all the data in records that is before the beginning of the .txt file
% - take the sleep state column of the .txt file and remove about 90% of it
% - set up the data data structure for autoscore.m
% - run autoscore.m
% - compare results to the human-scored .txt file using the kappa statistic




% set up a vector(matrix) of time stamps for the data in "records"
start_date = datenum(strcat(header.startdate, '.', header.starttime),'dd.mm.yy.HH.MM.SS')
end_date = addtodate(start_date,header.records*header.duration,'SS');
interval = 