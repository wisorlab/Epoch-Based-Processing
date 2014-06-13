function [WakeBoutCount,WakeBoutMean,SwsBoutCount,SwsBoutMean,RemsBoutCount,RemsBoutMean,BriefWakeCount]=DetectStateEpisodes(statearray);

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

WakeBoutCount=length(find((BoutStats(2,:)==0)));
SwsBoutCount=length(find((BoutStats(2,:)==1)));
RemsBoutCount=length(find((BoutStats(2,:)==2)));

BriefWakeCount=length(intersect(find(BoutStats(2,:)==0), find(BoutStats(3,:)<2)));

WakeBoutMean=sum(BoutStats(3,(find((BoutStats(2,:)==0)))))/WakeBoutCount;
SwsBoutMean=sum(BoutStats(3,(find((BoutStats(2,:)==1)))))/SwsBoutCount;
RemsBoutMean=sum(BoutStats(3,(find((BoutStats(2,:)==2)))))/RemsBoutCount;

