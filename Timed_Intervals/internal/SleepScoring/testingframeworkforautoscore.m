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

% filename='C:\Users\wisorlab\Desktop\BA1205.edf';
% txtfilename='D:\mrempe\strain_study_data\BA\BA_long\BA-120540.txt';

filename='C:\Users\wisorlab\Desktop\BL1181.edf';
txtfilename='C:\Users\wisorlab\Desktop\BL-118140.txt';

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
%record=record(:,(seconds_to_remove*(max(header.samples)/header.duration))-(max(header.samples)/2)+1:end);  %remove everything before the .txt file starts
record=record(:,(seconds_to_remove*(max(header.samples)/header.duration))+1:end);  %remove everything before the .txt file starts



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

  % randomly choose sequences of 10 manually scored training epochs
  % so that the total percentage scored is percentage_scored
  percentage_scored = 80;  % percentage of dataset that has been scored (the percentage that I don't set to unscored) 10 means 10%, 20 means 20%, etc.
  training_sequence_length_in_epochs = 10;
  trainingdata = sleepstate;
  num_sequences_scored = round((percentage_scored/100)*(length(sleepstate))/training_sequence_length_in_epochs);
  r=datasample(1:(length(sleepstate)/training_sequence_length_in_epochs),num_sequences_scored,'Replace',false); %randomly selected sequences of 10 epochs
  r=sort(r);   % r values are the starting points for the randomly-selected sequences of 10 epochs
  
for i=1:length(r)
	epoch_locs_scored(10*i-9:10*i) = r(i)*10-9:r(i)*10;
end

notscored=setdiff(1:length(sleepstate),epoch_locs_scored);
trainingdata(notscored)=8;

% reshape records into the format that autoscore.m wants and create the data cell array
samples_per_epoch = max(header.samples);
total_number_of_epochs = floor(size(record,2)/samples_per_epoch); %floor in case there is a partial epoch at the end

signal = 'EEG1';

disp('amount of edf signal being cut off:')
lost=size(record,2)-samples_per_epoch*total_number_of_epochs
disp(['this is equivalent to ', num2str(lost/1000), ' seconds'])

if strcmp(signal,'EEG1')
data.eeg = reshape(record(2,1:(samples_per_epoch*total_number_of_epochs)),samples_per_epoch,total_number_of_epochs);
elseif strcmp(signal,'EEG2')
data.eeg = reshape(record(4,1:(samples_per_epoch*total_number_of_epochs)),samples_per_epoch,total_number_of_epochs);
end
data.eeg_f = header.samples(2)/header.duration;
data.emg = reshape(record(3,1:(samples_per_epoch*total_number_of_epochs)),samples_per_epoch,total_number_of_epochs);
data.emg_f = header.samples(2)/header.duration;
data.score = trainingdata;

% Run autoscore.m to score the sleep data epoch-by-epoch (using the training data)
disp('Running autoscore')
[score] = autoscore(data);


% Compare the human-scoring to the autoscore
size(sleepstate)
size(score)
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
