function[SmoothedPercent,SmoothedData]=SmootheLactate(InputMatrix);
%this function was made to work with a 1-dimensional matrix (a vector called InputMatrix) that contains
%only the lactate data of interest. Other versions of the SmootheLactate
%algorithm extract the column representing lactate data from a 2-D matrix
%including Lactate data and other variables in other columns.

SmoothedData(:,1)=InputMatrix';
SmoothedData(1:10,2)=InputMatrix(1:10);
SmoothedCount=0;

for counter=11:length(InputMatrix)
    if InputMatrix(counter)-mean(InputMatrix(counter-10:counter-1))>10*std(InputMatrix(counter-10:counter-1))
        SmoothedData(counter,2)=mean(InputMatrix(counter-10:counter-1));
        SmoothedCount=SmoothedCount+1;
    elseif mean(InputMatrix(counter-10:counter-1))-InputMatrix(counter)>10*std(InputMatrix(counter-10:counter-1))
        SmoothedData(counter,2)=mean(InputMatrix(counter-10:counter-1));
        SmoothedCount=SmoothedCount+1;
    elseif InputMatrix(counter)<0
        SmoothedData(counter,2)=InputMatrix(counter-1);
        SmoothedCount=SmoothedCount+1;
    else
        SmoothedData(counter,2)=InputMatrix(counter);
    end
end
SmoothedPercent=SmoothedCount/length(SmoothedData)*100;
%plot(SmoothedData(:,1),'r')
%hold on
%plot(SmoothedData(:,2),'k')

return
