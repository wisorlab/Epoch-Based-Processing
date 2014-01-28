%=========================================================================
% Main analysis script for the 'Whisker-Opto Sleep Deprivation' experiment
%
% created by @jonbrennecke / http://github.com/jonbrennecke
%=========================================================================

addpath ./matlab-utils;
utils = getUtils;
[Excel, Workbooks, Sheets] = utils.xl.new();
sheets = utils.xl.addSheets(Excel,{ '5min Intervals' });
utils.xl.set(sheets{1},[1,1],{ 'Filename', 'Group', 'Dat' });

% open the file modal and get some '.txt' files
[files,path] = uigetfile({'*txt','Text Files (*.txt)';'*.*','All Files'; },'Select Data File(s)','MultiSelect','On');
if isstr(files), files = {files}; end

% [ char(ones(72,1)*'Data '), [1:72]' ]

for i=1:length(files)
	
	% extract meaningful data from the filename
	regexp(files{i},'(.*?)\s+(#\d+)\s+(\d+-\d+-\d+)\s+(\w+)\s+(\w+)\.(\w+)','tokens');
	nameparts = nameparts{1,1};

	% and write to Excel
	utils.xl.set(sheets{1},[1,i+1],{ files{i}, nameparts{4} });

	lines = utils.os.open([ path files{i} ]);

	% create several data arrays (for each sensor) from the file
	for j=1:length(lines)
		lines{j} = utils.std.split(lines{j}','\t'); 
		if j>2
			bio(j) = str2num( lines{j,1}{3} );
			eeg1(j) = mean( str2num( [lines{j,1}{4:43}] ) );
			eeg2(j) = mean( str2num( [lines{j,1}{44:end-1}] ) );
			emg(j) = str2num( lines{j,1}{end} );
		end
	end

	% the recording goes from 5am to 5pm, but we want to start sampling at 10am and end at 4pm
	% 10am is 5 hours into the recording, and
	% 5 hrs @ 6 samples / min => 1800 samples into the recording
	% 4pm is 1hr from the end of the recording, and 
	% 1 hr @ 6 samples / min => 360 samples from the end

	% toss out the first two elements (empty)
	% so start at '1800 + 3 'and end at 'end - 360'
	bio = bio(1803:end-360);
	emg = emg(1803:end-360);
	eeg1 = eeg1(1803:end-360);
	eeg2 = eeg2(1803:end-360);

	% divide the data into chunks of 30 samples
	% since 5 min * 6 samples/min = 30 samples
	% then average each 5 min window to one sample
	bio = mean( utils.std.slice(bio,30), 2);
	emg = mean( utils.std.slice(emg,30), 2);
	eeg1 = mean( utils.std.slice(eeg1,30), 2);
	eeg2 = mean( utils.std.slice(eeg2,30), 2);

	ival = 6 / 72;

	% plotting...
	% figure; hold on;
	% set(gca,'Color','black');
	% title('EEGs and EMG')
	% plot([ival:ival:6],emg,'g')
	% plot([ival:ival:6],eeg1,'b')
	% plot([ival:ival:6],eeg2,'y')

	% figure; hold on;
	% title('Bio Sensor')
	% set(gca,'Color','black');
	% plot([ival:ival:6],bio,'r')


	% finally output the biosensor data to Excel
	utils.xl.set(sheets{1},[3,i+1],{ bio' });

end