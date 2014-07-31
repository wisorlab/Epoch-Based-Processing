function TESTAUTOSCOREBATCHMODE(signal,edf_directory,txt_directory)

% usage: AUTOSCOREBATCHMODE(signal,edf_directory,txt_directory)
%
% signal:  'EEG1' or 'EEG2'
% edf_directory:  where the edf files are kept  (don't forget the final \)
% txt_directory:  where the .txt files are kept  (don't forget the final \)
%

directory_plus_extension=strcat(edf_directory,'*.edf');
edf_files=dir(directory_plus_extension);

for i=1:length(edf_files)
	% find the corresponding txt file (for each edf file)
	%filestring = % find everything between B and .edf, including the B. This should be the filename, with some modification BL1181.edf -> BL-118140.txt
	edf_files(i).name
	animal_number = edf_files(i).name(3:6);
	txtfile = strcat(txt_directory,'BA-',num2str(animal_number),'40.txt')

	%txtfile = strcat('D:\mrempe\strain_study_data\BA\BA_long\BA-',num2str(animal_number),'40.txt')

	[data,human_scored_state_vector] = process_data_for_autoscore(signal,strcat(edf_directory,edf_files(i).name),txtfile);
	computer_scored_state_vector = autoscore(data);
	[global_agreement(i),wake_percent_agreement(i),SWS_percent_agreement(i),REM_percent_agreement(i)]=compute_agreement(human_scored_state_vector,computer_scored_state_vector);
	kappa(i) = compute_kappa(human_scored_state_vector,computer_scored_state_vector);
clear data human_scored_state_vector
end


figure
boxplot([wake_percent_agreement,SWS_percent_agreement,REM_percent_agreement,global_agreement,kappa],['Wake' 'SWS' 'REM' 'Overall' 'Kappa'], ...
	'plotstyle','compact','boxstyle','filled','colors','rb');