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

addpath ..  % this is where importdatafile.m is 

filename='C:\Users\wisorlab\Desktop\BA1205.edf';
txtfilename='D:\mrempe\strain_study_data\BA\BA_long\BA-120540.txt';

% filename='C:\Users\wisorlab\Desktop\BL1181.edf';
% txtfilename='C:\Users\wisorlab\Desktop\BL-118140.txt';

% call edfread first to get headers and records
disp('Calling edfread')
[header,record]=edfread(filename);

% read in the .txt file so I can make use of the sleep state data.
disp('Reading in .txt file')
[numdatafromtxt,textdatafromtxt]=importdatafile(txtfilename);

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
  percentage_scored = 5;  % percentage of dataset that has been scored (the percentage that I don't set to unscored) 10 means 10%, 20 means 20%, etc.
%   training_sequence_length_in_epochs = 10;
   trainingdata = sleepstate;
%   num_sequences_scored = round((percentage_scored/100)*(length(sleepstate))/training_sequence_length_in_epochs);
%   r=datasample(1:(length(sleepstate)/training_sequence_length_in_epochs),num_sequences_scored,'Replace',false); %randomly selected sequences of 10 epochs
%   r=sort(r);   % r values are the starting points for the randomly-selected sequences of 10 epochs
  
% for i=1:length(r)
% 	epoch_locs_scored(10*i-9:10*i) = r(i)*10-9:r(i)*10;
% end


% Another approach: Find regions between 10AM and 2PM and choose random epochs in these 
% regions that contain at least 10% of each of the 3 states.
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
trainingdata(notscored)=8;

% reshape records into the format that autoscore.m wants and create the cell array called data
samples_per_epoch = max(header.samples);
total_number_of_epochs = floor(size(record,2)/samples_per_epoch); %floor in case there is a partial epoch at the end


signal = 'EEG2';


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
score = autoscore(data);

%Try using the 7 vectors of data from the PCA approach, but with a Naive Bayes approach instead

%[scoreFeatures,errFeatures] = classify(Features, Features(training, :),data.score(training),'diagquadratic',[.62 .33 .05]); % Naive Bayes

[global_agreement,wake_percent_agreement,SWS_percent_agreement,REM_percent_agreement]=compute_agreement(sleepstate,score)



% Compare the human-scoring to the autoscore
% First by computing kappa
kappa = compute_kappa(sleepstate,score)


figure
plot(sleepstate)
hold on 
plot(score,'r')
hold off

% make a scatterplot like Brankack et al 2010
%Brankack(data)




% set up a vector(matrix) of time stamps for the data in "records"
% timestamps is an 
% start_date = datenum(strcat(header.startdate, '.', header.starttime),'dd.mm.yy.HH.MM.SS')
% end_date = addtodate(start_date,header.records*header.duration,'second');
% interval = 1/(max(header.samples)/header.duration)/60/60/24;  %days
% timestamps = datestr(start_date:interval:end_date);

% cut off all the data in records that is before the beginning of the .txt file
