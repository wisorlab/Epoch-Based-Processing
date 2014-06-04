function [Fig_handle,error]=Figure2_script(directory)
%usage: [Fig_handle,error]=Figure2_script(directory)
%
% directory: directory where the data file is located ('data_files/BL/fig1_file')
% This function creates a figure demonstrating the lactate 
% model fitting the data. The figure has the following 4 panels:
%A: histogram of all data (SWS,REM,WAKE) showing LA and UA initially. 
%B: lacate data and the moving upper and lower asymptotes
%C: contour plot of error like previous figure but with several NM guesses on it. 
%D: Best fit of model to data with colored data points like in 



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

  PhysioVars(:,2)=LactateSmoothed(1:size(data,1));
  PhysioVars(:,3) = mean(data(:,3:5),2); 
  PhysioVars(:,4) = mean(data(:,43:45),2);
  
  PhysioVars(:,3) = medianfiltervectorized(PhysioVars(:,3),2);
  PhysioVars(:,4) = medianfiltervectorized(PhysioVars(:,4),2);

% make the frequency histogram for initial lactate data
  [LA,UA,hist_handle]=make_frequency_plot(PhysioVars,window_length,'lactate',0);
  F=figure; 
  subplot(2,3,1)
  xbins=linspace(0,max(PhysioVars(1:(window_length)*360+1,2)),30);
  [nall,xall]=hist(PhysioVars(1:(window_length)*360+1,2),xbins);
  h=barh(xall,nall);
  %axis([0 19.5 0 500])
  axis([0 500 0 19.5])
  xlabel('LACTATE SIGNAL [nA]')  
  ylabel('FREQUENCY ')
  hold on
  % l1=line([LA(1) LA(1)],[0 max(nall)],'LineStyle','--'); %vertical
  % l2=line([UA(1) UA(1)],[0 max(nall)],'LineStyle','--');
  l1=line([0 max(nall)],[LA(1) LA(1)],'LineStyle','--'); %horizontal
  l2=line([0 max(nall)],[UA(1) UA(1)],'LineStyle','--');  
  hold off
  ahand=gca;

  mask=(window_length/2)*360+1:size(PhysioVars,1)-(window_length/2)*360;


  dt=1/360;  % assuming data points are every 10 seconds and t is in hours 
 

% COMPUTING LOOP
% use the nelder_mead algorithm to find the global minimum error
  guesses=[0.5 1;1.5 1;1 2]; % three starting guesses
  [best_tau_i,best_tau_d,best_error,iters]=nelder_mead_for_lactate(guesses,1,1000,1e-9,0,PhysioVars,dt,LA,UA,window_length,mask);
  [best_tau_i2,best_tau_d2,best_error2]=nelder_mead_for_lactate(5*rand(3,2),1,1000,1e-9,0,PhysioVars,dt,LA,UA,window_length,mask);
  ti_diff=abs(best_tau_i2-best_tau_i)
  td_diff=abs(best_tau_d2-best_tau_d)
  


  Ti=best_tau_i;    %output the best taus
  Td=best_tau_d;

% run one more time with best fit and plot it (add a plot with circles)
  S=run_S_model(PhysioVars,dt,(LA(1)+UA(1))/2,LA,UA,Ti,Td,window_length,1,file(1).name);
  dhand=gca;
  axis([0 45 0 20])
  %legend('wake','sleep','rem','best fit model')
  hgsave(gcf,'best_fit.fig');
  t=0:dt:dt*(size(PhysioVars,1)-1);
  tS=t((window_length/2)*360+1:end-(window_length/2)*360);
 
  figure(F)  % change back to the subplot figure
  subplot(2,3,5:6)
  only_sleep_indices=find(PhysioVars(:,1)==1);
  only_wake_indices=find(PhysioVars(:,1)==0);
  only_rem_indices=find(PhysioVars(:,1)==2);
  sleep_lactate=PhysioVars(only_sleep_indices,2);
  wake_lactate=PhysioVars(only_wake_indices,2);
  rem_lactate=PhysioVars(only_rem_indices,2);

  scatter(t(only_wake_indices),wake_lactate,25,'r')
  
  hold on
  scatter(t(only_sleep_indices),sleep_lactate,25,'k')
  scatter(t(only_rem_indices),rem_lactate,25,'c')
  plot(tS,S)   
  legend('wake','sleep','rem','best fit model')
  legend BOXOFF
  hold off
xlabel


% Moving window panel
  figure(F)  % change back to the subplot figure
  %figure
  subplot(2,3,2:3)  
  plot(t,PhysioVars(:,2),'o','MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeColor',[0.5 0.5 0.5])
  hold on
  tS=t((window_length/2)*360+1:end-(window_length/2)*360);
  %plot(tS,S,'k')
  plot(tS,LA,'k--')
  plot(tS,UA,'k--')
  ylabel('lactate')
  xlabel('Time (hours)')
  axis([0 45 0 20])
  axes('Position',[.82 .78 .07 .07])
  time_late= 38;  % time in hours to compute inset histogram 
  xbins_late=linspace(0,max(data(360*time_late-720:360*time_late+720)),30);
  [nlate,xlate]=hist(data(360*time_late-720:360*time_late+720),xbins);
  barh(xlate,nlate)
  box off
  axis([0 max(nlate) 0 19.5])
  axes('Position',[.5 .85 .07 .07])
  time_early= 8;  % time in hours to compute inset histogram 
  xbins_early=linspace(0,max(data(360*time_early-720:360*time_early+720)),30);
  [nearly,xearly]=hist(data(360*time_early-720:360*time_early+720),xbins);
  barh(xearly,nearly)
  box off
  axis([0 max(nearly) 0 19.5])
  hold off
  bhand=gca;  
 % end of moving limits panel


% ----------------------------------------------------
% add a contour plot like panel d and add it to Figure

tau_i=0.01:0.005:Ti+0.6*Ti;
tau_d=0.01:0.005:Td+0.6*Td;

error=zeros(length(tau_i),length(tau_d));



% COMPUTING LOOP
% run the model and compute error for all combinations of tau_i and tau_d
for i=1:length(tau_i)
  for j=1:length(tau_d)
    S=run_S_model(PhysioVars,dt,(LA(1)+UA(1))/2,LA,UA,tau_i(i),tau_d(j),window_length,0,''); % run model
   
    % compute error 
      error(i,j)=sqrt((sum((S'-PhysioVars([mask],2)).^2))/(size(PhysioVars,1)-720)); %RMSE
    
      
    % display progress only at intervals of .25*total 
    display_progress(length(tau_d)*(i-1)+j,length(tau_i)*length(tau_d));

  end
end

best_error=min(min(error));
[r,c]=find(error==min(min(error)));

disp(['best tau_i found using brute force: ' num2str(tau_i(r))]);
disp(['best tau_d found using brute force: ' num2str(tau_d(c))]);

%figure
subplot(2,3,4)
[X,Y]=meshgrid(tau_d,tau_i);
contour(X,Y,error,50,'LineColor',[0 0 0]);
hold on
line([tau_d(c) tau_d(c)],[0 tau_i(r)],'LineStyle','--','Color',[0 0 0])
line([0 tau_d(c)],[tau_i(r) tau_i(r)],'LineStyle','--','Color',[0 0 0])
plot(tau_d(c),tau_i(r),'.','MarkerSize',5)
plot(iters(:,1),iters(:,2),'x','MarkerSize',6)
hold off
xlabel('Td [h]')
ylabel('Ti [h]')
chand=gca;
% -- End of contour plot code --

% add the 4th panel to the subplot:
% P4=subplot(2,3,5:6);
% P4_pos=get(P4,'position'); %get its position
% delete(P4)
% P = copyobj(dhand,F);
% set(P,'position',P4_pos)
% C = {'xlim','ylim','color'};
% set(P,C,get(dhand,C))

% P4=subplot(2,3,5:6);
% f_c=openfig('best_fit.fig');
% % Identify axes to be copied 
% axes_to_be_copied = findobj(f_c,'type','axes', '-not', 'tag', 'legend');
% % Identify the Legend
% legend_to_be_copied = findobj(f_c,'type','axes', 'tag', 'legend');
% % Identify the children of this axes 
% chilred_to_be_copied = get(axes_to_be_copied,'children'); 
% % Identify orientation of the axes 
% [az,el] = view; 
% % Copy the children of the axes 
% copyobj(chilred_to_be_copied,P4);
% % If there is a legend
% if isfloat(legend_to_be_copied)
%     copyobj(legend_to_be_copied, F);
% end
% % Set the limits and orientation of the subplot as the original figure 
% set(P4,'Xlim',get(axes_to_be_copied,'XLim')) 
% set(P4,'Ylim',get(axes_to_be_copied,'YLim')) 
% set(P4,'Zlim',get(axes_to_be_copied,'ZLim')) 
% view(P4,[az,el]) 


% % --------------------------------------------
% % combine all the figures into one as subplots
% % in a new figure
%  F=figure;
%  P1=subplot(2,3,1);
%  P1_pos=get(P1,'position'); %get its position
%  delete(P1)
%  P2=subplot(2,3,2:3);
%  P2_pos=get(P2,'position');
%  delete(P2)
%  P3=subplot(2,3,4);
%  P3_pos=get(P3,'position');
%  delete(P3)
%  P4=subplot(2,3,5:6);
%  P4_pos=get(P4,'position'); %get its position
%  delete(P4)
 

%  P = copyobj(ahand,F);
%  set(P,'position',P1_pos)
%  C = {'xlim','ylim','color'};
%  set(P,C,get(ahand,C))
%  P=copyobj(bhand,F);
%  set(P,'position',P2_pos)
%  C = {'xlim','ylim','color'};
%  set(P,C,get(bhand,C))
%  P=copyobj(chand,F);
%  set(P,'position',P3_pos)
%  C = {'xlim','ylim','color'};
%  set(P,C,get(chand,C))
%  P = copyobj(dhand,F);
%  set(P,'position',P4_pos)
%  C = {'xlim','ylim','color'};
%  set(P,C,get(dhand,C))

Fig_handle = gcf;
