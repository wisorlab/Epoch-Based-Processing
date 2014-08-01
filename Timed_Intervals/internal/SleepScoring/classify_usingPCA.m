function [predicted_score,kappa,global_agreement,wake_agreement,SWS_agreement,REM_agreement]=classify_usingPCA(filename,signal,already_scored_by_human,restrict,writefile)
	% Usage: [predicted_score,kappa,global_agreement,wake_agreement,SWS_agreement,REM_agreement]=classify_usingPCA(filename,signal)
	%
	%
	% This function uses a Principal Component Analysis approach to classify the sleep state of each epoch of the file filename. 
	% The approach is based on Gilmour et al 2010, but instead of visually drawing lines separating states, this function 
	% calls classify.m to to draw curves around the respective regions. 
	%
	% 
	%
	% Inputs:
	%        filename:      name of the .txt file. This can either be partially-scored or fully scored. 
	%        signal:        'EEG1' or 'EEG2'.  Which signal to use.
	%        already_scored_by_human: a boolean, 1 if this file has been fully scored already by a person, 0 if it 
	%                                 has only had a subset scored by a person as training for the learning algorithm 
	%                                 and the rest of the epochs left blank.  This determines how unscored epochs are 
	%                                 handled. Sometimes in a fully-scored file blank epochs are considered wake, whereas 
	%                                 in a partially-scored file we think of blank epochs as the ones that need to be
	%                                 filled in by the learning algorithm.
	%        restrict:      1 if you want to restrict the dataset to only 8640 epochs, 0 if you don't. I needed this 
	%                       to compare 8640 epochs of 2sec epoch data to 8640 epochs of 10sec epoch data in comparePCAscoreepochlength.m
	%        writefile:     1 if you want to generate a new .txt file, 0 if you don't
	%
	%


if nargin==3
	restrict=0; writefile=0;
end
if nargin==4
	writefile=0;
end


	% -- First import the .txt file
	% data has columns: lactate, EEG1_0.5-1Hz, EEG1_1-2Hz etc.
	addpath ..  %where importdatafile.m lives
	[data,textdata]=importdatafile(filename);
	TimeStampMatrix = create_TimeStampMatrix_from_textdata(textdata);
	

% throw away all the data except for 8640 epochs if restrict is set to 1
if restrict
	% addpath ../../../../../../Brennecke/matlab-pipeline/Matlab/etc/matlab-utils/  % where DateTime is located
	% DT1=DateTime(textdata{1,1})
	tenAMlocs = find(TimeStampMatrix(4,:)==10 & TimeStampMatrix(5,:)==0 & TimeStampMatrix(6,:)==0); %10:00, 10:00AM
	data = data(tenAMlocs(1):tenAMlocs(1)+8640,:);
	textdata = textdata(tenAMlocs(1):tenAMlocs(1)+8640,:);
end
size(data)
size(textdata)
pause



    % Set up the sleep state as a variable
	SleepState=zeros(size(data,1),1);
	unscored_epochs=0;

	for i = 1:size(data,1)  
     if isempty(textdata{i,2})==1        % label unscored epochs with an 8
     	unscored_epochs=unscored_epochs+1;
     	SleepState(i)=8;                 
     elseif textdata{i,2}=='W'           % 0=Wake,1=SWS,2=REM, 5=artefact,
     	SleepState(i)=0;
     elseif textdata{i,2}=='S'
     	SleepState(i)=1;
     elseif textdata{i,2}=='P'
     	SleepState(i)=2;
     elseif textdata{i,2}=='R'
     	SleepState(i)=2;
     elseif sum(textdata{i,2}=='Tr')==2
        SleepState(i)=0;                  % call transitions wake
     elseif textdata{i,2}=='X'            % artefact
     	SleepState(i)=5; 
     else   
     	error('I found a sleep state that wasn''t W,S,P,R,Tr, or X');
     end
    end
	disp(['There were ',num2str(unscored_epochs), ' epochs, (' num2str(unscored_epochs/(length(SleepState))*100) '% of the total dataset), that were not scored.'])


if already_scored_by_human
	SleepState(find(SleepState==8))=0; %set unscored epochs to wake if the file has already been scored by a human
end
	   % % Set up the sleep state as a variable
	   % SleepState=zeros(size(data,1),1);
	   % for i = 1: size(data,1)               %0=Wake,1=SWS,2=REM, 5=artefact,8=not scored
	   % 	if textdata{i,2}=='W' 
	   % 		SleepState(i)=0;
	   % 	elseif textdata{i,2}=='S'
	   % 		SleepState(i)=1;
	   % 	elseif textdata{i,2}=='P'
	   % 		SleepState(i)=2;
	   % 	elseif textdata{i,2}=='R'
	   % 		SleepState(i)=2;
	   % 	elseif textdata{i,2}=='X'
	   % 		SleepState(i)=5;
	  	% elseif isempty(textdata{i,2})==1
	   % 		SleepState(i)=8;     %If a file is partially scored let the learning algorithm fill in the sleep state
	   % 	end
	   % end

% Handle artifacts 
  if length(find(SleepState(:,1)==5)) > 0
    disp('I found some artefacts')
    SleepState = handle_artefacts(SleepState);     % After this step there are no more epochs scored as 5
  end 




	% Set up the feature matrix, a la Gilmour etal 2010.
	% rows are data points, columns are delta	theta	low beta	high beta	EMG	Theta/delta	Beta/delta 
	% where delta = 1-4 Hz
	% 		theta = 5-9 Hz
	%		low beta = 10-20 Hz
	%		high beta = 30-40 Hz
	%		Theta/delta is the ratio of theta to delta
	%		Beta/delta is the ratio of beta to delta (here beta is defined as 15-30Hz)

	if strcmp(signal,'EEG1')
	   Feature(:,1) = sum(data(:,3:5),2);	%delta
	   Feature(:,2) = sum(data(:,7:10),2);	%theta
	   Feature(:,3) = sum(data(:,12:21),2);	%low beta
	   Feature(:,4) = sum(data(:,32:41),2);	%high beta
	   Feature(:,5) = data(:,end);				%EMG
	   Feature(:,6) = Feature(:,2)./Feature(:,1);
	   Feature(:,7) = sum(data(:,17:31),2)./Feature(:,1);
	end 

if strcmp(signal,'EEG2')  
	Feature(:,1) = sum(data(:,43:45),2);	%delta
	Feature(:,2) = sum(data(:,47:50),2);	%theta
	Feature(:,3) = sum(data(:,52:61),2);	%low beta
	Feature(:,4) = sum(data(:,72:81),2);	%high beta
	Feature(:,5) = data(:,end);				%EMG
	Feature(:,6) = Feature(:,2)./Feature(:,1);
	Feature(:,7) = sum(data(:,57:71),2)./Feature(:,1);
end


% Smoothing
for i=1:7
	Feature(:,i)=medianfiltervectorized(Feature(:,i),2);
end

% Compute the Principal Components
scalefactor = max(max(Feature))-min(min(Feature));
[Coeff,PCAvectors,latent,tsquared,explained]=pca((2*(Feature-max(max(Feature))))./scalefactor+1);
explained


% Determine if the file has been fully scored or not.
% If it has been fully scored keep only a portion of the scored .txt file
% and re-score the whole thing using PCA.

if already_scored_by_human
	% --- use the data from 10AM to 2PM as training data
	% Find the first instance of 10AM in the data
	tenAMlocs = find(TimeStampMatrix(4,:)==10 & TimeStampMatrix(5,:)==0 & TimeStampMatrix(6,:)==0); %10:00, 10:00AM
	ind_start = tenAMlocs(1);

	% Find first instance of 2PM that comes after the first instance of 10AM
	twoPMlocs = find(TimeStampMatrix(4,:)==14 & TimeStampMatrix(5,:)==0 & TimeStampMatrix(6,:)==0); %14:00, 2:00PM
	a=find(twoPMlocs>ind_start);    % only keep those that occur after ind_start
	ind_end = twoPMlocs(a(1));
	scored_rows = ind_start:ind_end;

	% choose a random 5 percent as training data
	%percent_scored = 5;             % this is case where file has been scored.  we're just re-scoring it using a random 5% for training.
	%scored_rows = datasample(1:length(PCAvectors),round((percent_scored/100)*length(PCAvectors)),'Replace',false);
else
	scored_rows=(SleepState<=2);    % 0-2=wake/SWS/REM, 8=not scored
end

% 
% % If it has only been partially scored (less than 90%) the rows marked with 8 are unscored.
% percent_of_rows_not_scored = length(find(SleepState==8))/length(SleepState);

% if percent_of_rows_not_scored>.10   % has not been fully scored 
% 	scored_rows=(SleepState<=2);    % 0-2=wake/SWS/REM, 8=not scored
% else 
% 	disp('in the rescoring case')
% 	percent_scored = 5;             % this is case where file has been scored.  we're just re-scoring it using a random 5% for training.
% 	scored_rows = datasample(1:length(PCAvectors),round((percent_scored/100)*length(PCAvectors)),'Replace',false);
% end

% Do quadratic discriminant analysis to classify each epoch into wake, SWS, or REM using the PCA vectors
predicted_sleep_state = classify(PCAvectors(:,1:3),PCAvectors(scored_rows,1:3),SleepState(scored_rows),'diaglinear');  % if you use diaglinear or diagQuadratic it's a Naive Bayes




% Compare human-scored vs computer scored
figure
gscatter(PCAvectors(:,1),PCAvectors(:,2),SleepState,[1 0 0; 0 0 1; 1 .5 0],'osd');
xlabel('PCA1')
ylabel('PCA2')
a = find(filename=='\');
title(['Human-scored data for file ', filename(a(end)+1:end)])
legend('Wake','SWS','REMS')

figure
gscatter(PCAvectors(:,1),PCAvectors(:,2),predicted_sleep_state,[1 0 0; 0 0 1; 1 .5 0],'osd');
xlabel('PCA1')
ylabel('PCA2')
a = find(filename=='\');
title(['Computer-scored data for file ', filename(a(end)+1:end)])
legend('Wake','SWS','REMS')


% Compute statistics about agreement 
kappa = compute_kappa(SleepState,predicted_sleep_state);
[global_agreement,wake_agreement,SWS_agreement,REM_agreement] = compute_agreement(SleepState,predicted_sleep_state);

predicted_score = predicted_sleep_state;

% export a new excel file where the column of sleep state has been overwritten with the computer-scored
% sleep states
if writefile
	write_scored_file(filename,predicted_score);
end
