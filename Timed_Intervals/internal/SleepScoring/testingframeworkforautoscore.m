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

filename='C:\Users\wisorlab\Desktop\BA1205.edf';
txtfilename='D:\mrempe\strain_study_data\BA\BA_long\BA-120540.txt';


% call edfread first to get headers and records
disp('Calling edfread')
[header,record]=edfread(filename);

% read in the .txt file so I can make use of the sleep state data.
disp('Reading in .txt file')
[numdatafromtxt,textdatafromtxt]=importdatafile(txtfilename);
txtstarttime=cell2mat(textdatafromtxt(1,1));
startvectxt = datevec(txtstarttime(2:end-3),'mm/dd/yyyy,HH:MM:SS'); % starting time and date from txt file
startvecedf = datevec(strcat(header.startdate,'.',header.starttime),'dd.mm.yy.HH.MM.SS'); % same from edf file
seconds_to_remove = etime(startvectxt,startvecedf);  %elapsed time (in seconds) between start of edf and start of txt file
record=record(:,(seconds_to_remove*(max(header.samples)/header.duration))-(max(header.samples)/2)+1:end);  %remove everything before the .txt file starts

% get the sleep state column of the .txt file 
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
      sleepstate(i)=0;  
    end
  end

  percentage_scored = .90;  % percentage of dataset that has been scored (the percentage that I don't set to unscored)
  locs=randi(length(sleepstate),1,round((1-percentage_scored)*length(sleepstate))); % locations to set to 8 (unscored)
  trainingdata = sleepstate;
  trainingdata(locs)=8;    % training data is like sleepstate with 90% turned to 8 (for autoscore.m)

% reshape records into the format that autoscore.m wants and create the data cell array
samples_per_epoch = max(header.samples);
total_number_of_epochs = size(record,2)/samples_per_epoch; 

signal = 'EEG1';

if strcmp(signal,'EEG1')
data.eeg = reshape(record(2,:),samples_per_epoch,total_number_of_epochs);
elseif strcmp(signal,'EEG2')
data.eeg = reshape(record(4,:),samples_per_epoch,total_number_of_epochs);
end
data.eeg_f = header.samples(2)/header.duration;
data.emg = reshape(record(3,:),samples_per_epoch,total_number_of_epochs);
data.emg_f = header.samples(2)/header.duration;
data.score = trainingdata;

% Run autoscore.m to score the sleep data epoch-by-epoch (using the training data)
disp('Running autoscore')
[score] = autoscore(data);


% Compare the human-scoring to the autoscore
figure
plot(sleepstate)
hold on 
plot(score,'r')
hold off


% set up a vector(matrix) of time stamps for the data in "records"
% timestamps is an 
% start_date = datenum(strcat(header.startdate, '.', header.starttime),'dd.mm.yy.HH.MM.SS')
% end_date = addtodate(start_date,header.records*header.duration,'second');
% interval = 1/(max(header.samples)/header.duration)/60/60/24;  %days
% timestamps = datestr(start_date:interval:end_date);

% cut off all the data in records that is before the beginning of the .txt file
