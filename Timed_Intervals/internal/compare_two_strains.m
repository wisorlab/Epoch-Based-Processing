function [taui1,taud1,taui2,taud2,hi,pvali,hd,pvald]=compare_two_strains(directory1,directory2,signal)
%USAGE:  [taui1,taud1,taud1,taud2,hi,pvali,hd,pvald]=compare_two_strains(directory1,directory2)

% This function calls ProcessLBatchMode.m to compute the Taui and Taud values 
% for each dataset in directory1 and then calls it again to do the same 
% thing for each dataset in directory2. 
% Then, the average values for Taui and Taud are returned for each dataset 
% and a student's t test is computed.
%
% INPUTS: 
% directory1:  directory where first strain data lives (e.g. 'data_files/AKR/' or something)
% directory2:  directory where second strain data lives (e.g. 'data_files/DBA/' or something)
% signal:  'delta1', 'delta2', or 'lactate' 
% 
% OUTPUTS:
% taui1:  The average Taui value for the first strain (corresponding to directory1)
% taud1:  The average Taud value for the first strain (corresponding to directory1)
% taui2:  The average Taui value for the second strain (directory2)
% taud2:  The average Taud value for the second strain (directory2)
% hi:     The result of the two-sample t-test for the taui values (0 or 1)
% pvali:  The p-value for the two-sample t-test for the taui values
% hd:     The result of the two-sample t-test for the taud values (0 or 1)
% pvald:  The p-value for the two-sample t-test for the taud values


% First call ProcessLBatchMode.m for the first strain
[signal1,state1,S1,Ti1,Td1]=PROCESSLBATCHMODE(directory1,signal);


% Next call ProcessLBatchMod.m for the second strain
[signal2,state2,S2,Ti2,Td2]=PROCESSLBATCHMODE(directory2,signal);


% Now perform t-tests and compute p-values
[hi,pvali]=ttest2(Ti1,Ti2,0.01,'both','unequal');
[hd,pvald]=ttest2(Td1,Td2,0.01,'both','unequal');

if hi==1
disp('the null hypothesis that the \tau_i values are from populations with equal means is rejected')
end

if hd==1
disp('the null hypothesis that the \tau_d values are from populations with equal means is rejected')
end





