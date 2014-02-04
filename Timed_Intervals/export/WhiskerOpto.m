%=========================================================================
% Main analysis script for the 'Thy1xCD1 Whisker/Opto Sleep Deprivation' experiment
%
% created by @jonbrennecke / http://github.com/jonbrennecke
%=========================================================================

clear

% look for 'matlab-utils' in the matlab folder
addpath ../../../Matlab/etc/matlab-utils/;

% create a new XL object
xl = XL;
sheets = xl.addSheets({ '5min Intervals' });

% create a header row with 'Data 1-72'
% TODO exchange 'data' for time... mod(10+(0:5:360)/60,12) or something
data = [ char(ones(72,1) * 'Data ' ) num2str( [1:72]' ) ];
xl.setCells( sheets{1}, [1,1], [ { 'Filename', 'Group' } mat2cell(data,ones(1,72))' ] );

% open the file dialog and get some '.txt' files
[files,path] = uigetfile({'*txt','Text Files (*.txt)';'*.*','All Files'; },'Select Data File(s)','MultiSelect','On');
if ischar(files), files = {files}; end

for i=1:length(files)
	
	% extract meaningful data from the filename
	nameparts = regexp(files{i},'(.*?)\s+(#\d+)\s+(\d+-\d+-\d+)\s+(\w+)\s+(\w+)\.(\w+)','tokens');
	nameparts = nameparts{1,1};

	% and write to Excel
    xl.setCells(sheets{1},[1,i+1],{ files{i}, nameparts{4} });

    % open the file as a cell array of lines (akin to Python's 'for line in
    % file' )
	lines = OS.open([ path files{i} ]);
    
    % we want to find the time in the file closest to 10:00 AM, and start there
    % extract the timestamp from the first line
    firstLine = Utils.split(lines{3}','\t');
    startTime = DateTime( firstLine{1} );

    % create a new DateTime object with the same date as 'startTime', but set time to 10:00 AM
    tenAM = startTime.clone();
    tenAM.hour = 10; tenAM.minute = 0; tenAM.second = 0;

    % if startTime is equal to or after 10AM, use startTime,
    % otherwise, find 10AM in the file and start there
    % FYI: DateTime.cmp() currently returns the number of seconds between the
    % DateTime objects
    if( tenAM.cmp(startTime) > 0 )
        
        % the file starts *before* 10AM, so we need to find 10:00 AM in the
        % file
        for j=3:length(lines)
            line = Utils.split(lines{j}','\t'); 
            if( tenAM.cmp( DateTime( line{1} ) ) == 0 )
                lineStart = j;
                break
            end
        end
    else
        
        % the file starts after or at 10:00 AM, so just start on the first
        % line of the file
        lineStart = 1;
    end

	% create several data arrays (for each sensor) from the file
	for j=lineStart:length(lines)
		lines{j} = Utils.split(lines{j}','\t'); 
		if j>2
			bio(j - lineStart + 1) = str2num( lines{j,1}{3} );
			eeg1(j - lineStart + 1) = mean( str2num( [lines{j,1}{4:43}] ) );
			eeg2(j - lineStart + 1) = mean( str2num( [lines{j,1}{44:end-1}] ) );
			emg(j - lineStart + 1) = str2num( lines{j,1}{end} );
		end
	end

    % the data in the sensor arrays now starts at 10:00 AM
    % to select the 6hr block we determine the following:
    % 6 hours * 60 min / hr * 6 samples / min = 2160 samples
	bio = bio(1:2160);
	emg = emg(1:2160);
	eeg1 = eeg1(1:2160);
	eeg2 = eeg2(1:2160);

	% divide the data into chunks of 30 samples
	% since 5 min * 6 samples/min = 30 samples
	% then average each 5 min window to one sample
	bio = mean( Utils.slice(bio,30), 2);
	emg = mean( Utils.slice(emg,30), 2);
	eeg1 = mean( Utils.slice(eeg1,30), 2);
	eeg2 = mean( Utils.slice(eeg2,30), 2);

	% plotting...
%   ival = 6 / 72;
% 	figure; hold on;
% 	set(gca,'Color','black');
% 	title('EEGs and EMG')
% 	plot([ival:ival:6],emg,'g')
% 	plot([ival:ival:6],eeg1,'b')
% 	plot([ival:ival:6],eeg2,'y')
% 
% 	figure; hold on;
% 	title('Bio Sensor')
% 	set(gca,'Color','black');
% 	plot([ival:ival:6],bio,'r')

	% finally output the biosensor data to Excel
    xl.setCells(sheets{1},[3,i+1],bio');

end