% compare the lactate signal from the .txt file to what I get from the .edf file (after averaging)

edf_lactate(1)=mean(record(1,1:10000));

for i=1:15478
	edf_lactate(i+1)=mean(record(1,10000*(i)-100:10000*(i+1)-100));
end

(round(edf_lactate(1:20).*100)./100)' 


figure
plot(numdatafromtxt(:,1))
hold on 
plot(edf_lactate,'r')
hold off
