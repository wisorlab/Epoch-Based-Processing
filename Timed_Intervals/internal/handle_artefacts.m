function CleanedUpVars = handle_artefacts(VarsWithArtefacts)
	%
	%Usage: CleanedUpVars = handle_artefacts(VarsWithArtefacts)
	%
	% This function reads in a matrix that has sleep state in the first
	% column, lactate data in the second column, and EEG and EMG data in the columns
	% after that.  
	% This function assumes that the first column contains sleep state information
	% 0=Wake, 1=Sleep, 2=REM, and 5=artefact. It will find each row (epoch) that has been scored 
	% as artefact and fill in a state value. 
	%
	% Logic: if the row immediately above and the row immediately below are the 
	% same state, just fill in the artefact rows with that state and 
	% set the EEG and EMG to the average of the value immediately above and immediately
	% below.  
% If the row above does not match the sleep state of the row below then I don't know what to do yet 


CleanedUpVars = VarsWithArtefacts;

% find all contiguous runs of epochs scored as 5 for artefact 
runs = contiguous(VarsWithArtefacts(:,1),5);
runs_matrix = runs{1,2};   % runs is a matrix where each row is a run. 1st column is index of run beginning. 2nd column is index of run end

for i=1:size(runs_matrix,1)
	if VarsWithArtefacts(runs_matrix(i,1)-1,1) == VarsWithArtefacts(runs_matrix(i,2)+1,1)
		state = VarsWithArtefacts(runs_matrix(i,1)-1,1);
		CleanedUpVars(runs_matrix(i,1):runs_matrix(i,2),1) = state;
	else
		state = mode(VarsWithArtefacts([runs_matrix(i,1)-6:runs_matrix(i,1)-1 runs_matrix(i,2)+1 runs+matrix(i,2)+6],1));
		CleanedUpVars(runs_matrix(i,1):runs_matrix(1,2),1) = state; %if state is not the same immediately before and after, just use the most common state 
	end
	CleanedUpVars(runs_matrix(i,1):runs_matrix(i,2),2:end) = mean(VarsWithArtefacts([runs_matrix(i,1)-1 runs_matrix(i,2)+1],2:end),2);
end
