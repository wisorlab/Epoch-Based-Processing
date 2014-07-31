function [BFlactate,BFdelta]=timing_test(N)
data_dir = 'D:\mrempe\strain_study_data\BL\long_files\'; 

[signal,state,bestS,UABFdelta,LABFdelta,timerBFdelta,tiBFdelta,tdBFdelta]=PROCESSLBATCHMODE(data_dir,'delta2','BruteForce');

% call PROCESSLBATCHMODE.m using brute force and lactate
[signal,state,bestS,UABFlactate,LABFlactate,timerBFlactate,tiBFlactate,tdBFlactate]=PROCESSLBATCHMODE(data_dir,'lactate','BruteForce');


BFlactate(1) = timerBFlactate
BFdelta(1) = timerBFdelta

% Now in the other order
[signal,state,bestS,UABFlactate,LABFlactate,timerBFlactate,tiBFlactate,tdBFlactate]=PROCESSLBATCHMODE(data_dir,'lactate','BruteForce');
[signal,state,bestS,UABFdelta,LABFdelta,timerBFdelta,tiBFdelta,tdBFdelta]=PROCESSLBATCHMODE(data_dir,'delta2','BruteForce');

BFlactate(2) = timerBFlactate
BFdelta(2) = timerBFdelta


%Now run each in a loop or something and take average times:
for i=1:N

end
