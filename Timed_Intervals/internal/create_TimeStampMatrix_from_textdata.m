function TimeStampMatrix=create_TimeStampMatrix_from_textdata(textdata)

for i=1:length(textdata)
    try
      TimeStampMatrix(:,i) = sscanf(textdata{i,1},'"%f/%f/%f,%f:%f:%f"');
    catch exception1
      try 
	TimeStampMatrix(:,i) = sscanf(textdata{i,1},'%f/%f/%f,%f:%f:%f');
      catch exception2 
        try   
          TimeStampMatrix(:,i) = sscanf(textdata{i,1},'%f/%f/%f %f:%f:%f');  
        catch exception3
        end  
      end
    end
   end