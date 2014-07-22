function [data,sleepstate]=process_data_for_autoscore(signal,edffile,txtfile)

% this function reads in an .edf file and a partially scored .txt file
% and processes them into the correct format so autoscore.m can do its thing. 

% INPUTS:
% signal:   EEG1 or EEG2
% edffile:  a sleep scoring file with extension .edf.  This gets read into MATLAB via edfread.m
% txtfile:  a scored (partially or fully) sleep file. Rows are epochs Columns contain lactate data, EEG data, and EMG data

% OUTPUT:
% data:   a structure with the following elements:
% data.eeg   from the edf file
% data.eeg_f
% data.emg    from the edf file
% data.emg_f
% data.score  from the txt file
% sleepstate  The human-scored


%edffile='C:\Users\wisorlab\Desktop\BA1205.edf';
%txtfile='D:\mrempe\strain_study_data\BA\BA_long\BA-120540.txt';

% filename='C:\Users\wisorlab\Desktop\BL1181.edf';
% txtfilename='C:\Users\wisorlab\Desktop\BL-118140.txt';

% call edfread first to get headers and records
disp('Calling edfread')
[header,record]=edfread(edffile);

% read in the .txt file so I can make use of the sleep state data.
disp('Reading in .txt file')
addpath .. % so I call importdatafile.m from the directory above instead of making multiple versions
[numdatafromtxt,textdatafromtxt]=importdatafile(txtfile);

% Sometimes the edf file starts before the .txt file, so cut off the beginning of the edf file
txtstarttime=cell2mat(textdatafromtxt(1,1));
startvectxt = datevec(txtstarttime(2:end-3),'mm/dd/yyyy,HH:MM:SS'); % starting time and date from txt file
startvecedf = datevec(strcat(header.startdate,'.',header.starttime),'dd.mm.yy.HH.MM.SS'); % same from edf file
seconds_to_remove = etime(startvectxt,startvecedf);  %elapsed time (in seconds) between start of edf and start of txt file
%record=record(:,(seconds_to_remove*(max(header.samples)/header.duration))-(max(header.samples)/2)+1:end);  %remove everything before the .txt file starts
record=record(:,(seconds_to_remove*(max(header.samples)/header.duration))+1:end);  %remove everything before the .txt file starts

% Sometimes the edf file ends later than the .txt file so cut off the end of the .edf file so the lengths match up
epochs_in_txt_file = size(numdatafromtxt,1);
if size(record,2) > max(header.samples)*epochs_in_txt_file
	record = record(:,1:max(header.samples)*epochs_in_txt_file);
end


% get the sleep state column of the .txt file and set empty entries to 8 (unscored)
sleepstate = zeros(size(numdatafromtxt,1),1);
for i = 1: size(numdatafromtxt,1)  
    if textdatafromtxt{i,2}=='W' 
      sleepstate(i)=0;
    elseif textdatafromtxt{i,2}=='S'
      sleepstate(i)=1;
    elseif textdatafromtxt{i,2}=='P'
      sleepstate(i)=2;
    elseif textdatafromtxt{i,2}=='R'
      sleepstate(i)=2;
    elseif isempty(textdatafromtxt{i,2})==1
      sleepstate(i)=8;  
    end
  end

% Compute epoch length from .txt file
epoch_length =  str2num(textdatafromtxt{2}(19:20))-str2num(textdatafromtxt{1}(19:20));  %in seconds

% This section is only if you are using a .txt file that has already been scored completely. Comment out the next 20 lines if 
% you are using a partially-scored txt file
percentage_scored = 5;  % percentage of dataset that has been scored (the percentage that I don't set to unscored) 10 means 10%, 20 means 20%, etc.
num_sequences_scored = round((percentage_scored/100)*length(sleepstate));
percent_wake = 0;
percent_SWS  = 0;
percent_REM  = 0;

indices_tenAM = find(not(cellfun('isempty',strfind(textdatafromtxt,'10:00:00'))));
indices_twoPM = find(not(cellfun('isempty',strfind(textdatafromtxt,'14:00:00'))));


while min([percent_wake percent_SWS percent_REM])<.10
	r=datasample([indices_tenAM(1):indices_twoPM(1) indices_tenAM(2):indices_twoPM(2)],num_sequences_scored,'Replace',false);
	percent_wake = length(find(sleepstate(r)==0))/length(r);
	percent_SWS  = length(find(sleepstate(r)==1))/length(r);
	percent_REM  = length(find(sleepstate(r)==2))/length(r);
end 
epoch_locs_scored=r;

notscored=setdiff(1:length(sleepstate),epoch_locs_scored);
trainingdata = sleepstate;
trainingdata(notscored)=8;


% If you are using a partially scored file, uncomment this line
%trainingdata = sleepstate;

% reshape records into the format that autoscore.m wants and create the cell array called data
samples_per_epoch = max(header.samples);
total_number_of_epochs = floor(size(record,2)/samples_per_epoch); %floor in case there is a partial epoch at the end


if strcmp(signal,'EEG1')
	data.eeg = reshape(record(2,1:(samples_per_epoch*total_number_of_epochs)),samples_per_epoch,total_number_of_epochs);
elseif strcmp(signal,'EEG2')
	data.eeg = reshape(record(4,1:(samples_per_epoch*total_number_of_epochs)),samples_per_epoch,total_number_of_epochs);
end
data.eeg_f = header.samples(2)/header.duration;
data.emg = reshape(record(3,1:(samples_per_epoch*total_number_of_epochs)),samples_per_epoch,total_number_of_epochs);
data.emg_f = header.samples(2)/header.duration;
data.score = trainingdata;


clear record trainingdata

