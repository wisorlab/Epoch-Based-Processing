function [signal_data,state_data,best_S,UppA,LowA,Timer,Taui,Taud]=PROCESSLBATCHMODE(directory,signal,algorithm)
% USAGE: [best_S,Taui,Taud]=ProcessLBatchMode(directory,signal,algorithm)
%
% INPUTS:
% directory is where the data files are (include the entire directory. i.e. 'D:\mrempe\strain_study_data\BL\long_files\'
%
% signal can be one of three options: 'lactate', 'delta1' or 'delta2',
% where delta1 means the delta power in EEG1 and delta2 is delta power in EEG2
%
% algorithm is either 'NelderMead' or 'BruteForce' and determines how the optimum 
% values of taui and taud are found. 
% 
%  
% OUTPUTS:
% signal_data: a cell array containing vectors of either delta power or lactate, one for each file in the directory
% best_S:  a cell array containing the best fit curve S, one for each file in the directory
% Taui:    a vector of the rise time time constant, one value for each file in the directory
% Taud:    a vector of the fall time time constant, one value for each file in the directory
% 

%profile -memory on



directory_plus_extension=strcat(directory,'*.txt');


files = dir(directory_plus_extension);     % the dir function returns a cell array containing the name, date, bytes and date-as-number as a single array for each txt file in this directory.

HowManyFiles = length(files) % Need to know the number of files to process.  This number is encoded as the variable "HowManyFiles". 

% for FileCounter = 1:length(files)   %Runs the following set of commands for each file meeting criterion within the current directory.
  
%   InputFileList {FileCounter,1} = files (FileCounter).name;  %InputFileList is a Cell Array of Strings, meaning an array of strings that are not necessarily uniform in number of characters.
%   InputFileList {FileCounter,2} = FileCounter; %Each row in InputFileList contains the name of one *.txt file followed by the row number associated with that file in InputFileList. 
% end 
				% the use of '{}' to signify array positions identifies this array as a cell array of strings
%Here, InputFileList receives the names associated with each file in the directory that meets inclusion criteria.  (FileCounter,1) identifies a cell within InputFileList.  
% '.name' indicates that we need to add the name to InputFileList at element (FileCounter,1).  So now we have a cell array of Strings, in which all input files are listed. 
% For more information on batch processing, see: http://blogs.mathworks.com/steve/2006/06/06/batch-processing/#1


% ---
% LOADING LOOP
% First loop through the files, load all the data and decide if 
% I will use each data set or not
% --- 
for FileCounter=1:length(files)  %this loop imports the data files one-by-one and processes the data in them into output files.   
clear PhysioVars
%clear dynamic_range
%clear TimeStampMatrix   

  [data,textdata]=importdatafile(files(FileCounter).name,directory);%importfile returns data (a matrix) and textdata (a cell array)
  display(files(FileCounter).name) % One matrix (textdata) holds the date/time stamp and sleep state.  The other (data) holds the lactate and EEG data.
  

% Compute the length of one epoch here using TimeStampMatrix
% I used to just compute the difference in seconds between first time stamp and second,
% but that was not robust enough since sometimes there is a change in minutes between those two timestamps
% textdata has mm/dd/yyy,HH:MM:SS AM format, but may or may not include quotes or single quotes,
% so to be more robust, find the second colon and use that to get the seconds field of the time stamp
f=find(textdata{1,1}==':');   % Find all locations of the colon in the first time stamp
first_colon_loc = f(1);   
last_colon_loc = f(2);
hour_first_time_stamp    = str2num(textdata{1,1}(first_colon_loc-2))*10+str2num(textdata{1,1}(first_colon_loc-1));  
hour_second_time_stamp   = str2num(textdata{2,1}(first_colon_loc-2))*10+str2num(textdata{2,1}(first_colon_loc-1));  
minute_first_time_stamp  = str2num(textdata{1,1}(first_colon_loc+1))*10+str2num(textdata{1,1}(first_colon_loc+2));
minute_second_time_stamp = str2num(textdata{2,1}(first_colon_loc+1))*10+str2num(textdata{2,1}(first_colon_loc+2));
second_first_time_stamp  = str2num(textdata{1,1}(last_colon_loc+1))*10+str2num(textdata{1,1}(last_colon_loc+2));
second_second_time_stamp = str2num(textdata{2,1}(last_colon_loc+1))*10+str2num(textdata{2,1}(last_colon_loc+2));

epoch_length_in_seconds(FileCounter)=etime([2014 2 28 hour_second_time_stamp minute_second_time_stamp second_second_time_stamp],[2014 2 28 hour_first_time_stamp minute_first_time_stamp second_first_time_stamp]);

%epoch_length_in_seconds = (textdata{2,1}(last_colon_loc+1)*10+textdata{2,1}(last_colon_loc+2))-(textdata{1,1}(last_colon_loc+1)*10+textdata{1,1}(last_colon_loc+2))
%epoch_length_in_seconds = (textdata{2,1}(19)*10+textdata{2,1}(20))-(textdata{1,1}(19)*10+textdata{1,1}(20)) 


  if strcmp(signal,'lactate')      % cut off data if using lactate sensor
    lactate_cutoff_time_hours=60;  % time in hours to cut off the lactate signal (lifetime of sensor)
    lactate_cutoff_time_rows=lactate_cutoff_time_hours*60*60/epoch_length_in_seconds(FileCounter);
    
    LactateSmoothed=medianfiltervectorized(data(:,1),1);

   if size(data,1) > lactate_cutoff_time_rows
      data=data(1:lactate_cutoff_time_rows,:);
    end
  end

 		                                                   
 
  PhysioVars=zeros(size(data,1),4);
 

  missing_values=0;
  for i = 1: size(data,1)  
    %i

    if isempty(textdata{i,2})==1        % call unscored epochs wake
      missing_values=missing_values+1;
      PhysioVars(i,1)=0;  

    elseif textdata{i,2}=='W' 
      PhysioVars(i,1)=0;
    elseif textdata{i,2}=='S'
      PhysioVars(i,1)=1;
    elseif textdata{i,2}=='P'
      PhysioVars(i,1)=2;
    elseif textdata{i,2}=='R'
      PhysioVars(i,1)=2;
    elseif sum(textdata{i,2}=='Tr')==2
      PhysioVars(i,1)=0;                 % call transitions wake
    elseif textdata{i,2}=='X'            %artefact
      PhysioVars(i,1)=5; 
				else   
				  error('I found a sleep state that wasn''t W,S,P,R,Tr, or X');
    end
  end
  disp(['There were ',num2str(missing_values), ' epochs that were not scored.'])

 
  if strcmp(signal,'lactate') 
    PhysioVars(:,2)=LactateSmoothed(1:size(data,1));
  else PhysioVars(:,2)=data(:,1);
  end
  
  PhysioVars(:,3) = sum(data(:,3:5),2);   % as many rows as there are rows in the input file, EEG1 delta power (1-4Hz) 
  PhysioVars(:,4) = sum(data(:,43:45),2); % as many rows as there are rows in the input file, EEG2 delta power (1-4Hz)
  
  d1smoothed = medianfiltervectorized(PhysioVars(:,3),2); 
  d2smoothed = medianfiltervectorized(PhysioVars(:,4),2);
  
  PhysioVars(:,3) = d1smoothed;
  PhysioVars(:,4) = d2smoothed;
  


 % Handle artifacts 
  if length(find(PhysioVars(:,1)==5)) > 0
    PhysioVars = handle_artefacts(PhysioVars);
  end 




  state_data{FileCounter} = PhysioVars(:,1);
  if strcmp(signal,'lactate')
    signal_data{FileCounter} = PhysioVars(:,2);
  elseif strcmp(signal,'delta1')
    signal_data{FileCounter} = PhysioVars(:,3);
  elseif strcmp(signal,'delta2')
    signal_data{FileCounter} = PhysioVars(:,4);
  end

% Compute the dynamic range for each data file
  dynamic_range(FileCounter) = quantile(signal_data{FileCounter},.9)-quantile(signal_data{FileCounter},.1);

% Cut off all data before 8:00PM 
  % first read in all the timestamp data into a matrix
  TimeStampMatrix{FileCounter} = create_TimeStampMatrix_from_textdata(textdata);
  locs_of_start_times = find(TimeStampMatrix{FileCounter}(4,:)==20 & TimeStampMatrix{FileCounter}(5,:)==0 & TimeStampMatrix{FileCounter}(6,:)==0); %the twenty is for 20:00, 8:00PM
 

 
  state_data{FileCounter}  = state_data{FileCounter}(locs_of_start_times(1):end,1);  %reset state_data and signal_data cell arrays to only include the data starting at 8:00PM
  signal_data{FileCounter} = signal_data{FileCounter}(locs_of_start_times(1):end,1);
  TimeStampMatrix{FileCounter} = TimeStampMatrix{FileCounter}(:,locs_of_start_times(1):end);


  % compute the length of the datafile in hours 
  start_time = TimeStampMatrix{FileCounter}(:,locs_of_start_times(1));
  end_time   = TimeStampMatrix{FileCounter}(:,end);

  start_time(1:3) = [start_time(3); start_time(1); start_time(2)];
  end_time(1:3) = [end_time(3); end_time(1); end_time(2)];
  length_of_recording = etime(end_time',start_time');
  length_of_recording = length_of_recording/60/60; % convert from seconds to hours

 


% ----- 
% For lactate simulations, allow the lactate sensor to settle down:
% Find the first two NREM episodes of at least 1 minute, and start 
% the simulation at the end of the second 1-minute NREM episode
% ----
if strcmp(signal,'lactate')
   ind_of_second_NREM_episode_end = find_first_two_NREM_episodes(state_data{FileCounter});
   state_data{FileCounter}  = state_data{FileCounter}(ind_of_second_NREM_episode_end:end);
   signal_data{FileCounter} = signal_data{FileCounter}(ind_of_second_NREM_episode_end:end);
end







end % end of looping through files to load data, decide which files to exclude, and cut off lactate transient

% ------
% Exclusion criteria:
% Compute the dynamic range for each dataset and 
% include only the datasets with the 7 largest
% dynamic ranges.
%------
% [sorteddata,sortIndex]=sort(dynamic_range,'descend');
% if length(dynamic_range) >= 20
% Indices_of_largest = sortIndex(1:20);  % 20 largest dynamic ranges
% else
% Indices_of_largest = sortIndex;
% end

% % reset signal_data and state_data cell arrays to only include files that haven't been excluded 
% % by our exclusion rule
% state_data  = state_data(Indices_of_largest);
% signal_data = signal_data(Indices_of_largest);
% files       = files(Indices_of_largest);




%---
% COMPUTING LOOP
%---
% Now that I've loaded all the data and determined which datasets to keep (and simulate)
disp('Starting computing loop...')
for FileCounter=1:length(files)
  disp(['File number ', num2str(FileCounter), ' of ', num2str(length(files))])
  display(files(FileCounter).name)
  if strcmp(algorithm,'NelderMead')  
	[Ti,Td,LA,UA,best_error,error_instant,S,ElapsedTime] = Franken_like_model_with_nelder_mead([state_data{FileCounter} signal_data{FileCounter}],signal,files(FileCounter).name,epoch_length_in_seconds(FileCounter));
  end
  if strcmp(algorithm,'BruteForce')
	[Ti,Td,LA,UA,best_error,error_instant,S,ElapsedTime] = Franken_like_model([state_data{FileCounter} signal_data{FileCounter}],signal,files(FileCounter).name,epoch_length_in_seconds(FileCounter)); %for brute-force 
  end

[LAnormalized,UAnormalized]=normalizeLAUA(LA,UA,[state_data{FileCounter} signal_data{FileCounter}],TimeStampMatrix{FileCounter});

  Taui(FileCounter) = Ti;
  Taud(FileCounter) = Td;
  LowA{FileCounter} = LAnormalized;  %normalized LA
  UppA{FileCounter} = UAnormalized;  %normalized UA
  Timer(FileCounter) = ElapsedTime;
  Error(FileCounter) = best_error;
  Error2(FileCounter) = error_instant;
  %delete(findall(0,'Type','figure')); %if you want to delete all figures before next run
  
  % populate cell array with S output
  best_S{FileCounter} = S;

 

end  %end of looping through files
    
%write a DataSourceInfo tab
% disp('Writing data to an Excel file...')
% addpath ../../../../../Brennecke/matlab-pipeline/Matlab/etc/matlab-utils/;
% xl=XL;
% sheet = xl.Sheets.Item(1);

% col1_name{1} = 'Taui Values';                                       % column headers
% first_header_cells=xl.setCells(sheet,[1,1],col1_name,'false','true');
% set(first_header_cells.Font, 'Bold', true)
% col2_name{1} = 'Taud Values';
% second_header_cells=xl.setCells(sheet,[2,1],col2_name,'false','true');
% set(second_header_cells.Font, 'Bold', true)
% col3_name{1} = 'CPU time';
% third_header_cells=xl.setCells(sheet,[3,1],col3_name,'false','true');
% set(third_header_cells.Font, 'Bold', true)


% xl.setCells(sheet,[1,2],Taui','false','false');

% xl.sourceInfo(mfilename('fullpath'));                                % DataSourceInfo tab
% xl.saveAs(strcat('PROCESSLBATCHMODE output', '.txt'));



% make a bar graph showing the error in the model and the error using 
% the instant model that follows the lactate upper and lower bounds and 
% switches in-between them if the sleep state changes
% if strcmp(signal,'lactate')
%   figure
%   bar([1,2],[mean(Error)/mean(Error) mean(Error2)/mean(Error)])
%   set(gca,'XTickLabel',{'Model fit','instant model'})
%   hold on
%   h=errorbar([1 2],[mean(Error)/mean(Error) mean(Error2)/mean(Error)],[std(Error)/sqrt(length(Error)) std(Error2)/sqrt(length(Error2))]); 
%   %set(h(2),'LineStyle','none','Marker','s','MarkerEdgeColor','k')
  
%   d=daspect;
%   daspect([d(1)*2 d(2) d(3)])
  
%   title('Error between model fit and instant model that follows UA or LA')
% end

load chirp % this assigns chirp to the variable y
sound  (y)



%profile viewer