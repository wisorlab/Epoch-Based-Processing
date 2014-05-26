function [signal_data,state_data,best_S,Taui,Taud]=PROCESSLBATCHMODE(directory,signal)
% USAGE: [best_S,Taui,Taud]=ProcessLBatchMode(directory,signal)
%
%
% signal can be one of three options: 'lactate', 'delta1' or 'delta2',
% where delta1 means the delta power in EEG1 and delta2 is delta power in EEG2
% 
% OUTPUTS:
% signal_data: a cell array containing vectors of either delta power or lactate, one for each file in the directory
% best_S:  a cell array containing the best fit curve S, one for each file in the directory
% Taui:    a vector of the rise time time constant, one value for each file in the directory
% Taud:    a vector of the fall time time constant, one value for each fiel in the directory
% new comment

%profile on

directory_plus_extension=strcat(directory,'*.txt');


files = dir(directory_plus_extension);     % the dir function returns a cell array containing the name, date, bytes and date-as-number as a single array for each txt file in this directory.

HowManyFiles = length(files) % Need to know the number of files to process.  This number is encoded as the variable "HowManyFiles". 

for FileCounter = 1:length(files)   %Runs the following set of commands for each file meeting criterion within the current directory.
  
  InputFileList {FileCounter,1} = files (FileCounter).name;  %InputFileList is a Cell Array of Strings, meaning an array of strings that are not necessarily uniform in number of characters.
  InputFileList {FileCounter,2} = FileCounter; %Each row in InputFileList contains the name of one *.txt file followed by the row number associated with that file in InputFileList. 
end  % the use of '{}' to signify array positions identifies this array as a cell array of strings
%Here, InputFileList receives the names associated with each file in the directory that meets inclusion criteria.  (FileCounter,1) identifies a cell within InputFileList.  
% '.name' indicates that we need to add the name to InputFileList at element (FileCounter,1).  So now we have a cell array of Strings, in which all input files are listed. 
% For more information on batch processing, see: http://blogs.mathworks.com/steve/2006/06/06/batch-processing/#1

for FileCounter=1:length(files)  %this loop imports the data files one-by-one and processes the data in them into output files.   
  
  [data,textdata]=importdatafile(files(FileCounter).name,directory);%importfile returns data (a matrix) and textdata (a cell array)
  display(files(FileCounter).name) % One matrix (textdata) holds the date/time stamp and sleep state.  The other (data) holds the lactate and EEG data.
  
  if strcmp(signal,'lactate')      % cut off data if using lactate sensor
    lactate_cutoff_time_hours=60;  % time in hours to cut off the lactate signal (lifetime of sensor)
    lactate_cutoff_time_rows=lactate_cutoff_time_hours*60*6;
    
    LactateSmoothed=medianfiltervectorized(data(:,1),1);

   if size(data,1) > lactate_cutoff_time_rows
      data=data(1:lactate_cutoff_time_rows,:);
    end
  end

 		                                                   
 
  PhysioVars=zeros(size(data,1),4);
 

  missing_values=0;
  for i = 1: size(data,1)  
    if textdata{i,2}=='W' 
      PhysioVars(i,1)=0;
    elseif textdata{i,2}=='S'
      PhysioVars(i,1)=1;
    elseif textdata{i,2}=='P'
      PhysioVars(i,1)=2;
    elseif textdata{i,2}=='R'
      PhysioVars(i,1)=2;
    elseif isempty(textdata{i,2})==1
      missing_values=missing_values+1;
      PhysioVars(i,1)=0;  
				% else   
				%   PhysioVars(i,1)=0;
    end
  end
  missing_values


 
  if strcmp(signal,'lactate') 
    PhysioVars(:,2)=LactateSmoothed(1:size(data,1));
  else PhysioVars(:,2)=data(:,1);
  end
  
  PhysioVars(:,3) = mean(data(:,3:5),2); % fftonly is a matrix with as many rows as there are rows in the input file, and 40 columns corresponding to the EEG1 and EEG2 ffts in 1 Hz bins.
  PhysioVars(:,4) = mean(data(:,43:45),2); % fftonly is a matrix with as many rows as there are rows in the input file, and 40 columns corresponding to the EEG1 and EEG2 ffts in 1 Hz bins.
  
  d1smoothed = medianfiltervectorized(PhysioVars(:,3),2); 
  d2smoothed = medianfiltervectorized(PhysioVars(:,4),2);
  
  PhysioVars(:,3) = d1smoothed;
  PhysioVars(:,4) = d2smoothed;
  
  state_data{FileCounter} = PhysioVars(:,1);
  if strcmp(signal,'lactate')
    signal_data{FileCounter} = PhysioVars(:,2);
  elseif strcmp(signal,'delta1')
    signal_data{FileCounter} = PhysioVars(:,3);
  elseif strcmp(signal,'delta2')
    signal_data{FileCounter} = PhysioVars(:,4);
  end

				% Compute the dynamic range for each data file
  dynamic_range(FileCounter) = quantile(signal_data{FileCounter},.9)-quantile(signal_data{FileCounter},.1)
  
  
  [Ti,Td,LA,UA,best_error,error_instant,S] = Franken_like_model_with_nelder_mead(PhysioVars,signal,files(FileCounter).name);

  Taui(FileCounter) = Ti
  Taud(FileCounter) = Td
  %LowA(FileCounter,:)=LA;
  %UppA(FileCounter,:)=UA;
  Error(FileCounter)  = best_error;
  Error2(FileCounter) = error_instant;
  %delete(findall(0,'Type','figure')); %if you want to delete all figures before next run
  
  % populate cell array with S output
  best_S{FileCounter} = S;



end  %end of looping through files
    
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