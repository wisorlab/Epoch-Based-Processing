function [Fig_handle,error]=Figure1_script(directory,signal)
%usage: [Fig_handle,error]=Figure1_script(directory,signal)
%
% directory is where the data file is located 'D:\mrempe\strain_study_data\BL\fig1_file\
%
% signal is  'delta1', or 'delta2'
%
% This script recreates Figure 1 from Franken et al 2001
% using our data and using EEG as the signal.  
  
  if ~(strcmp(signal,'delta1') | strcmp(signal,'delta2'))
    error('input must be delta1 or delta2')
  end

  %directory = 'data_files/BL/fig1_file/';
  file = dir(strcat(directory,'*.txt'));

  window_length = 4;

  [data,textdata]=importdatafile(file(1).name,directory);

  PhysioVars=zeros(size(data,1),4);
  for i = 1: size(data,1)  
    if textdata{i,2}=='W' 
      PhysioVars(i,1)=0;
    elseif textdata{i,2}=='S'
      PhysioVars(i,1)=1;
    elseif textdata{i,2}=='P'
      PhysioVars(i,1)=2;
    elseif textdata{i,2}=='R'
      PhysioVars(i,1)=2;
    elseif isempty(textdata{i,2})==1
      PhysioVars(i,1)=0;  
    end
  end

  LactateSmoothed=medianfiltervectorized(data(:,1),1);

  if strcmp(signal,'lactate') 
    PhysioVars(:,2)=LactateSmoothed(1:size(data,1));
  else PhysioVars(:,2)=data(:,1);
  end
  
  PhysioVars(:,3) = mean(data(:,3:5),2); 
  PhysioVars(:,4) = mean(data(:,43:45),2);
  
  PhysioVars(:,3) = medianfiltervectorized(PhysioVars(:,3),2);
  PhysioVars(:,4) = medianfiltervectorized(PhysioVars(:,4),2);

% make the frequency histogram
  [LA,UA,hist_handle]=make_frequency_plot(PhysioVars,window_length,signal);
  bhand=gca;


  if(strcmp(signal,'delta1') | strcmp(signal,'delta2'))
    [t_mdpt_SWS,data_at_SWS_midpoints,t_mdpt_indices]=find_all_SWS_episodes2(PhysioVars,signal);
  end


  mask=(window_length/2)*360+1:size(PhysioVars,1)-(window_length/2)*360;


  dt=1/360;  % assuming data points are every 10 seconds and t is in hours 
  % tau_i=[0.05:0.01:1 1.1:.5:5];  %1:.12:25
  % tau_d=[0.05:0.01:1 1.1:.5:5]; %0.1:.025:5
  % error=zeros(length(tau_i),length(tau_d));

% COMPUTING LOOP
% use the nelder_mead algorithm to find the global 
% minimum error
  guesses=[0.5 1;1.5 1;1 2]; % three starting guesses
  if strcmp(signal,'delta1') | strcmp(signal,'delta2')
    [best_tau_i,best_tau_d,best_error]=nelder_mead_for_delta(guesses,1,1000,1e-9,0,PhysioVars,dt,LA,UA,t_mdpt_indices,data_at_SWS_midpoints);
  end
  
 
    
  Ti=best_tau_i;    %output the best taus
  Td=best_tau_d;

% run one more time with best fit and plot it (add a plot with circles)
 
  if strcmp(signal,'delta1') | strcmp(signal,'delta2')
    S=run_S_model(PhysioVars,dt,(LA(1)+UA(1))/2,LA,UA,Ti,Td,window_length,0,file(1).name);
  end

  t=0:dt:dt*(size(PhysioVars,1)-1);


  if strcmp(signal,'delta1') | strcmp(signal,'delta2') 
    figure
    scatter(t_mdpt_SWS,data_at_SWS_midpoints,30,'MarkerEdgeColor','k', ...
    'LineWidth',1.5,'MarkerFaceColor',[0.5 0.5 0.5])
    hold on
    plot(t,S,'k','LineWidth',1)
    ylabel('Delta power')
    xlabel('TIME [h]')
    hold off
     ehand=gca;
  end
% ------ end of panel e---------
% run S model 3 times and overlay the plots like Franken Fig 1 panel c
% first starting with UA as S(1):
     if strcmp(signal,'delta1') | strcmp(signal,'delta2')  
       Shi(1)=UA;
       for i=1:size(PhysioVars,1)-1
	 if PhysioVars(i,1)==0 || PhysioVars(i,1)==2 %wake or REM
	   Shi(i+1)=UA-(UA-Shi(i))*exp(-dt/Ti);
	 elseif(PhysioVars(i,1)==1) %sleep
	   Shi(i+1)=LA+(Shi(i)-LA)*exp(-dt/Td);
	 end
       end
       
				% now re-run it starting with LA as S(1):
       Slow(1)=LA;
       for i=1:size(PhysioVars,1)-1
	 if PhysioVars(i,1)==0 || PhysioVars(i,1)==2 %wake or REM
	   Slow(i+1)=UA-(UA-Slow(i))*exp(-dt/Ti);
	 elseif(PhysioVars(i,1)==1) %sleep
	   Slow(i+1)=LA+(Slow(i)-LA)*exp(-dt/Td);
	 end
       end
       
       figure
       hold on      
       plot(t,Shi,'k','LineWidth',1.5)
       plot(t,Slow,'k','LineWidth',1.5)
       plot(t,S,'k','LineWidth',1.5)
       plot(t,S(1)*ones(size(t)),'k--')
       plot(t,UA*ones(size(t)),'k--') % modify if lactate is used
       plot(t,LA*ones(size(t)),'k--') % modify if lactate is used (don't need ones)
				%plot(t_mdpt_SWS,(LA-250)*ones(size(t_mdpt_SWS)),'ks','MarkerFaceColor','k','MarkerSize',10) % only plot SWS episodes longer than 5 minutes
       for i=1:length(t_mdpt_SWS)
	 line([t_mdpt_SWS(i) t_mdpt_SWS(i)],[LA-300 LA-200],'LineWidth',4,'Color',[0 0 0])
       end
       axis([0 24 LA-400 UA+200]) 
       xlabel('TIME [h]')
       ylabel('')
       hold off
       chand=gca;
     end



%% --- MAKE PANEL A JUST TO DEMONSTRATE METHOD, NOT USING REAL DATA -- 
%% -------------------------------------------------------------------
figure
tpanela=0:1500;
p=round(length(tpanela)/10);
LAa=3;
UAa=13;
dta=1;
Tia=400;
Tda=150;
state=zeros(size(tpanela));
state(1:p)=2; %wake
state(p+1:3*p)=1; %sleep
state(3*p+1:4*p)=0; %REM
state(4*p+1:6*p)=1; %sleep
state(6*p+1:9*p)=2; %w
state(9*p+1:end)=1;
Spanela(1) = (2/3)*(UAa-LAa)+LAa; 
for i=1:size(state,2)-1
    if state(i)==0 || state(i)==2 %wake or REM
      Spanela(i+1)=UAa-(UAa-Spanela(i))*exp(-dta/Tia);
    elseif(state(i)==1) %sleep
      Spanela(i+1)=LAa+(Spanela(i)-LAa)*exp(-dta/Tda);
    end
  end
mask=1:20:length(tpanela);
hold on
plot(tpanela,Spanela,'k')
plot(tpanela(mask),Spanela(mask),'k.','LineWidth',2,'MarkerSize',20)
%plot(state,'ks','MarkerFaceColor','k')
for i=1:length(tpanela)
  if state(i)==0
    line([tpanela(i) tpanela(i)],[-0.5 0.5],'LineWidth',1,'Color',[0 0 0])
  elseif state(i)==1
    line([tpanela(i) tpanela(i)],[0.5 1.5],'LineWidth',1,'Color',[0 0 0])
       elseif state(i)==2
	 line([tpanela(i) tpanela(i)],[1.5 2.5],'LineWidth',1,'Color',[0 0 0])
      end
    end

plot(tpanela,UAa*ones(size(tpanela)),'k--')
plot(tpanela,LAa*ones(size(tpanela)),'k--')
hold off
xlabel('t [10s-epochs]')
set(gca,'ytick',[])
set(gca,'yticklabel',[])
ahand=gca;

% add a contour plot like panel d and add it to Figure
mask=(window_length/2)*360+1:size(PhysioVars,1)-(window_length/2)*360;


dt=1/360;  % assuming data points are every 10 seconds and t is in hours 
if strcmp(signal,'delta1') | strcmp(signal,'delta2')
  tau_i=0.1:.1:4;  %1:.12:25
  tau_d=0.1:0.1:4; %0.1:.025:5
end

if strcmp(signal,'lactate')
tau_i=0.1:0.1:Ti+0.6*Ti;
tau_d=0.1:0.1:Td+0.6*Td;
end

error=zeros(length(tau_i),length(tau_d));

% COMPUTING LOOP
% run the model and compute error for all combinations of tau_i and tau_d
for i=1:length(tau_i)
  for j=1:length(tau_d)
    S=run_S_model(PhysioVars,dt,(LA(1)+UA(1))/2,LA,UA,tau_i(i),tau_d(j),window_length,0,''); % run model
   
    % compute error (depending on if delta power or lactate was used)
    if strcmp(signal,'delta1') | strcmp(signal,'delta2')
      error(i,j)=sqrt((sum((S([t_mdpt_indices])-data_at_SWS_midpoints).^2))/length(t_mdpt_indices)); %RMSE
    elseif strcmp(signal,'lactate')
      error(i,j)=sqrt((sum((S'-PhysioVars([mask],2)).^2))/(size(PhysioVars,1)-720)); %RMSE
    end
      
    % display progress only at intervals of .25*total 
    display_progress(length(tau_d)*(i-1)+j,length(tau_i)*length(tau_d));

  end
end

best_error=min(min(error));
[r,c]=find(error==min(min(error)));
disp(['best tau_i found using brute force: ' num2str(tau_i(r))]);
disp(['best tau_d found using brute force: ' num2str(tau_d(c))]);

figure
[X,Y]=meshgrid(tau_d,tau_i);
contour(X,Y,error,50,'LineColor',[0 0 0])
hold on
line([tau_d(c) tau_d(c)],[0 tau_i(r)],'LineStyle','--','Color',[0 0 0])
line([0 tau_d(c)],[tau_i(r) tau_i(r)],'LineStyle','--','Color',[0 0 0])
plot(tau_d(c),tau_i(r),'.','MarkerSize',5)
hold off
xlabel('Td [h]')
ylabel('Ti [h]')
if strcmp(signal,'delta1') | strcmp(signal,'delta2')
dhand=gca;
end


% -----------------------------------------------------------------------------------------------------
% combine all figures into one as subplots
 F=figure;
 P1=subplot(2,3,1);
 P1_pos=get(P1,'position'); %get its position
 delete(P1)
 P2=subplot(2,3,2);
 P2_pos=get(P2,'position');
 delete(P2)
 P3=subplot(2,3,3);
 P3_pos=get(P3,'position'); %get its position
 delete(P3)
 P4=subplot(2,3,4);
 P4_pos=get(P4,'position');
 delete(P4)
 P5=subplot(2,3,5:6);
 P5_pos=get(P5,'position'); %get its position
 delete(P5)
 

 P = copyobj(ahand,F);
 set(P,'position',P1_pos)
 C = {'xlim','ylim','color'};
 set(P,C,get(ahand,C))
 P=copyobj(bhand,F);
 set(P,'position',P2_pos)
 C = {'xlim','ylim','color'};
 set(P,C,get(bhand,C))
 P = copyobj(chand,F);
 set(P,'position',P3_pos)
 C = {'xlim','ylim','color'};
 set(P,C,get(chand,C))
 P=copyobj(dhand,F);
 set(P,'position',P4_pos)
 C = {'xlim','ylim','color'};
 set(P,C,get(dhand,C))
 P = copyobj(ehand,F);
 set(P,'position',P5_pos)
 C = {'xlim','ylim','color'};
 set(P,C,get(ehand,C))




 
Fig_handle = gcf;

