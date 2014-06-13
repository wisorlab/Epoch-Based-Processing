function [WakeBoutCount,WakeBoutMean,SwsBoutCount,SwsBoutMean,RemsBoutCount,RemsBoutMean,BriefWakeCount]=DetectStateEpisodesIntervalMode(statearray,AnalysisInterval);
%statearray is the sequence of state scores for the ENTIRE recording.  0=wake; 1=SWS; 2= REMS.

%DO NOT run this function on sub-intervals of data.  Run it on entire sequence of epochs. It will divide output data into intervals of duration AnalysisInterval.

%This function will divide that array into appropriate intervals based on the AnalysisInterval input.

%OUTPUTS WILL BE VECTORS OF LENGTH floor(length(statearray)/AnalysisInterval);

try
    if (class (statearray(1))=='char')   %this loop converts a char array into a double array if needed
        states = lower (statearray);
        statearray=NaN(1,length(states));
        statearray(states=='w')=0;
        statearray(states=='s')=1;
        statearray(states=='r')=2;
        statearray(isnan(statearray))=0;
    end
end

NumIntervals=floor(length(statearray)/AnalysisInterval);
IntervalStart=1:AnalysisInterval:(AnalysisInterval*NumIntervals);
IntervalStop=AnalysisInterval:AnalysisInterval:(AnalysisInterval*NumIntervals);

transition=zeros(1,length(statearray));  %create a vector that will record state transitions
transition(2:end)= diff(statearray)~=0;  %if the state at time X NE state at time X-1, then  it is a transition

BoutStats=zeros(3,length(find(transition==1)));  %BoutStats array has three rows and one column for each detected transition in statearray.
%Each transition terminates a bout/episode.
%BoutStats(1,:) will return the position in the array of the end of the bout.
%BoutStats(2,:) will return the state classification of that bout.
%BoutStats(3,:) will return the duration in epochs of that bout.

BoutStats(1,:)=find(transition==1)-1;
BoutStats(2,:)=statearray(BoutStats(1,:));
BoutStats(3,1)=BoutStats(1,1);
BoutStats(3,2:end)=diff(BoutStats(1,:));

AllWakeBouts=find(BoutStats(2,:)==0);
AllSWSBouts=find(BoutStats(2,:)==1);
AllRemsBouts=find(BoutStats(2,:)==2);
AllBriefWake=intersect(AllWakeBouts, find(BoutStats(3,:)<2));

WakeBoutMean=NaN(1,NumIntervals);
SwsBoutMean=NaN(1,NumIntervals);
RemsBoutMean=NaN(1,NumIntervals);
WakeBoutCount=NaN(1,NumIntervals);
SwsBoutCount=NaN(1,NumIntervals);
RemsBoutCount=NaN(1,NumIntervals);
BriefWakeCount=NaN(1,NumIntervals);

if  length(find(transition > 0))  % only do this is there are transitions in the file; it could crash if there is one state throughout
    for i=1:NumIntervals
        
        BoutsInThisBin=intersect(find(BoutStats(1,:) > IntervalStart(i)),find(BoutStats(1,:) < IntervalStop(i)));
        
        WakeBoutsInThisBin=intersect(BoutsInThisBin,AllWakeBouts);
        SwsBoutsInThisBin=intersect(BoutsInThisBin,AllSWSBouts);
        RemsBoutsInThisBin=intersect(BoutsInThisBin,AllRemsBouts);
        WakeBoutCount(i)=length(WakeBoutsInThisBin);
        if WakeBoutCount(i)<1
            WakeBoutCount(i)=NaN;
        end
        SwsBoutCount(i)=length(SwsBoutsInThisBin);
        RemsBoutCount(i)=length(RemsBoutsInThisBin);
        BriefWakeCount(i)=length(intersect(WakeBoutsInThisBin,AllBriefWake));
        
        try
            WakeBoutMean(i)=sum(BoutStats(3,WakeBoutsInThisBin))/WakeBoutCount(i);
        end
        try
            SwsBoutMean(i)=sum(BoutStats(3,SwsBoutsInThisBin))/SwsBoutCount(i);
        end
        try
            RemsBoutMean(i)=sum(BoutStats(3,RemsBoutsInThisBin))/RemsBoutCount(i);
        end
        
    end
end % loop that identifies bouts and assigns them to appropriate analysis interval.
