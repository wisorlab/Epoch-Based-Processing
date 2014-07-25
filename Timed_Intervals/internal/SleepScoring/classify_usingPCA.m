function [predicted_score,kappa,global_agreement,wake_agreement,SWS_agreement,REM_agreement]=classify_usingPCA(filename,signal,already-scored)
	% Usage: [predicted_score,kappa,global_agreement,wake_agreement,SWS_agreement,REM_agreement]=classify_usingPCA(filename,signal)
	%
	%
	% This funtion uses a Principal Component Analysis approach to classify the sleep state of each epoch of the file filename. 
	% The approach is based on Gilmour et al 2010, but instead of visually drawing lines separating states, this function 
	% calls classify.m to to draw curves around the respective regions. 
	%
	% As of 7.23.14 this function reads in an already-scored .txt file and takes a subset of the file as training data. 
	% I will update it to read it a partially-scored file for the training 
	%
	%
	% Inputs:
	%        filename:      name of the .txt file. This can either be partially-scored or fully scored. 
	%        signal:        'EEG1' or 'EEG2'.  Which signal to use.
	%        already_scored: 
	%
	% As of now, this reads in a fully-scored .txt file and only keeps a random 5% of the data. 
	% Modify it to read in a partially-scored .txt file 
	% TO DO: should this write to the excel file (or a new name excel file) so a user could just call 
	% this function on a partially-scored .txt file and end up with a fully-scored .txt file?



	% -- First import the .txt file
	% data has columns: lactate, EEG1_0.5-1Hz, EEG1_1-2Hz etc.
	addpath ..  %where importdatafile.m lives
	[data,textdata]=importdatafile(filename);

	   % Set up the sleep state as a variable
	   SleepState=zeros(size(data,1),1);
	   for i = 1: size(data,1)               %0=Wake,1=SWS,2=REM, 5=artefact,8=not scored
	   	if textdata{i,2}=='W' 
	   		SleepState(i)=0;
	   	elseif textdata{i,2}=='S'
	   		SleepState(i)=1;
	   	elseif textdata{i,2}=='P'
	   		SleepState(i)=2;
	   	elseif textdata{i,2}=='R'
	   		SleepState(i)=2;
	   	elseif textdata{i,2}=='X'
	   		SleepState(i)=5;
	   	elseif textdata{i,2}=='XX'
	   		SleepState(i)=5;
	   	elseif isempty(textdata{i,2})==1
	   		SleepState(i)=8;     %If a file is partially scored let the learning algorithm fill in the sleep state
	   	end
	   end

% Handle artifacts 
  if length(find(PhysioVars(:,1)==5)) > 0
    PhysioVars = Handle_artifacts(PhysioVars);
  end 

	% Set up the feature matrix, a la Gilmour.
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
	   Feature(:,5) = data(:,82);				%EMG
	   Feature(:,6) = Feature(:,2)./Feature(:,1);
	   Feature(:,7) = sum(data(:,17:31),2)./Feature(:,1);
	end 

if strcmp(signal,'EEG2')  
	Feature(:,1) = sum(data(:,43:45),2);	%delta
	Feature(:,2) = sum(data(:,47:50),2);	%theta
	Feature(:,3) = sum(data(:,52:61),2);	%low beta
	Feature(:,4) = sum(data(:,72:81),2);	%high beta
	Feature(:,5) = data(:,82);				%EMG
	Feature(:,6) = Feature(:,2)./Feature(:,1);
	Feature(:,7) = sum(data(:,57:71),2)./Feature(:,1);
end


% Smoothing
for i=1:7
	FeatureSmoothed(:,i)=medianfiltervectorized(Feature(:,i),2);
end

% Compute the Principal Components
scalefactor = max(max(Feature))-min(min(Feature));
[Coeff,PCAvectors,latent,tsquared,explained]=pca((2*(Feature-max(max(Feature))))./scalefactor+1);
explained



% Keep only a portion of the scored .txt file 
percent_scored = 5;
scored_rows = datasample(1:length(PCAvectors),round((percent_scored/100)*length(PCAvectors)),'Replace',false);

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
%write_scored_file(filename,predicted_score)

