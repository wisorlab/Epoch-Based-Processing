function [Fig_handle,error,xs,ys]=Figure2_script(directory,signal)
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

  if strcmp(signal,'delta1')
    data=PhysioVars(:,3);
  elseif strcmp(signal,'delta2')
    data=PhysioVars(:,4);
  end


if strcmp(signal,'delta1')
  [t_mdpt_SWS,data_at_SWS_midpoints,t_mdpt_indices]=find_all_SWS_episodes2([PhysioVars(:,1) PhysioVars(:,3)]);
elseif strcmp(signal,'delta2')
  [t_mdpt_SWS,data_at_SWS_midpoints,t_mdpt_indices]=find_all_SWS_episodes2([PhysioVars(:,1) PhysioVars(:,4)]);
end



% --- Frequency Histogram ---
  F=figure; 
  subplot(3,3,1)
  [LA,UA]=make_frequency_plot(PhysioVars,window_length,signal);
  
  if strcmp(signal,'lactate')  % lactate
    xbins=linspace(0,max(PhysioVars(1:(window_length)*360+1,2)),30);
    [nall,xall]=hist(PhysioVars(1:(window_length)*360+1,2),xbins);
    h=barh(xall,nall);
    %axis([0 19.5 0 500])
    axis([0 400 0 40])
    xlabel('LACTATE SIGNAL [nA]')  
    ylabel('FREQUENCY')
    hold on
    l1=line([0 max(nall)+300],[LA(1) LA(1)],'LineStyle','--'); %horizontal
    l2=line([0 max(nall)+300],[UA(1) UA(1)],'LineStyle','--');  
    hold off

  elseif strcmp(signal,'delta1') || strcmp(signal,'delta2') % delta
    sleepdata=data(PhysioVars(:,1)==1);
    remdata=data(PhysioVars(:,1)==2);
    wakedata=data(PhysioVars(:,1)==0);
    xbins=linspace(0,max(sleepdata),30);

  % compute the histograms
    [ns,xs]=hist(sleepdata,xbins);  %sleep data
    [nr,xr]=hist(remdata,xbins);   %REM data 
    difference=ns-nr;  % need to find where this is 0
    id=find(diff(difference >= 0)); % finds crossings of the difference
                                  % vector, (keep only last one)
  
    if(isempty(id)) % if they don't cross
      loc=find(nr>0);  % find first non-zero bin of REM
      LA=xr(loc(1)); % set to first non-zero bin  
    else
      id=id(end);
      LA = xs(id)-(difference(id)*(xs(id+1)-xs(id))/(difference(id+1)-difference(id)));
    end
    UA=quantile(sleepdata,.9);
    barh(xs,ns) 
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor',[0.5 0.5 0.5],'EdgeColor','k')
    hold on
    barh(xr,nr)
    plot(0:max(ns),LA) % plot horizontal line at LA
    plot(0:max(ns),UA)
    hold off  
    xlabel('DELTA POWER [mV^2]')
    if strcmp(signal,'lactate')  
      axis([0 500 0 19])
    else
      axis([0 800 0 10000])
    end
  end
  ahand=gca;

  

% Nelder Mead for best fit
  mask=(window_length/2)*360+1:size(PhysioVars,1)-(window_length/2)*360;
  dt=1/360;  % assuming data points are every 10 seconds and t is in hours 
 
initial_guess = [1 1];     % one starting guess
% NM loop
  if strcmp(signal,'delta1')
    [bestparamsNM,best_error] = fminsearch(@(p) myobjectivefunction(signal,t_mdpt_indices,data_at_SWS_midpoints, ...
								    [PhysioVars(:,1) PhysioVars(:,3)],dt,LA,UA,window_length,mask,p),initial_guess,optimset('TolX',1e-3));
  end
  if  strcmp(signal,'delta2')
    [bestparamsNM,best_error] = fminsearch(@(p) myobjectivefunction(signal,t_mdpt_indices,data_at_SWS_midpoints, ...
								    [PhysioVars(:,1) PhysioVars(:,4)],dt,LA,UA,window_length,mask,p),initial_guess,optimset('TolX',1e-3));
  end  
  if strcmp(signal,'lactate')
    [bestparamsNM,best_error] = fminsearch(@(p) myobjectivefunction(signal,0,0,[PhysioVars(:,1) PhysioVars(:,2)],dt,LA,UA, ...
								    window_length,mask,p),initial_guess,optimset('TolX',1e-3));
  end
  % guesses=[0.5 1;1.5 1;1 2]; % three starting guesses
  % [best_tau_i,best_tau_d,best_error,iters]=nelder_mead_for_lactate(guesses,1,1000,1e-9,0,PhysioVars,dt,LA,UA,window_length,mask);
  % [best_tau_i2,best_tau_d2,best_error2]=nelder_mead_for_lactate(5*rand(3,2),1,1000,1e-9,0,PhysioVars,dt,LA,UA,window_length,mask);
  % ti_diff=abs(best_tau_i2-best_tau_i)
  % td_diff=abs(best_tau_d2-best_tau_d)
  best_tau_i=bestparamsNM(1);
  best_tau_d=bestparamsNM(2);


  Ti=best_tau_i;    %output the best taus
  Td=best_tau_d;

% run one more time with best fit (according to NM) and plot it (add a plot with circles)
  if  strcmp(signal,'lactate')
    best_SNM=run_S_model(PhysioVars,dt,(LA(1)+UA(1))/2,LA,UA,Ti,Td,window_length,1,file(1).name);
  elseif strcmp(signal,'delta1') || strcmp(signal,'delta2')
    best_SNM=run_S_model(PhysioVars,dt,(LA(1)+UA(1))/2,LA,UA,Ti,Td,window_length,0,file(1).name);
  end
  %dhand=gca;
  %axis([0 45 0 20])
  %legend('wake','sleep','rem','best fit model')
  %hgsave(gcf,'best_fit.fig');
  t=0:dt:dt*(size(PhysioVars,1)-1);
  tS=t((window_length/2)*360+1:end-(window_length/2)*360);
 
  figure(F)  % change back to the subplot figure
  subplot(3,3,8:9)
  if strcmp(signal,'lactate')
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
    plot(tS,best_SNM)   
    legend('wake','sleep','rem','best fit model')
    legend BOXOFF
    ylabel('LACTATE SIGNAL [nA]')
    xlabel('TIME [h]')
    hold off
    axis([0 45 0 40])
  elseif strcmp(signal,'delta1') || strcmp(signal,'delta2')
    scatter(t_mdpt_SWS,data_at_SWS_midpoints,30,'MarkerEdgeColor','k', ...
	    'LineWidth',1.5,'MarkerFaceColor',[0.5 0.5 0.5])
    hold on
    plot(t,best_SNM,'k','LineWidth',1)
    ylabel('Delta power')
    xlabel('TIME [h]')
    axis([0 45 2000 6000])
    hold off
end


% Moving window panel
  figure(F)  % change back to the subplot figure
  %figure
  subplot(3,3,2:3)  
  if strcmp(signal,'lactate')
    plot(t,PhysioVars(:,2),'o','MarkerFaceColor',[0.5 0.5 0.5],'MarkerEdgeColor',[0.5 0.5 0.5])
    box off  
  elseif strcmp(signal,'delta1') ||  strcmp(signal,'delta2')
     scatter(t_mdpt_SWS,data_at_SWS_midpoints,30,'MarkerEdgeColor','k', ...
	    'LineWidth',1.5,'MarkerFaceColor',[0.5 0.5 0.5])
   end

hold on
  tS=t((window_length/2)*360+1:end-(window_length/2)*360);
  %plot(tS,S,'k')
  plot(tS,LA,'k--')
  plot(tS,UA,'k--')
  if strcmp(signal,'lactate')  
    ylabel('LACTATE SIGNAL [nA]')
  axis([0 45 0 40])
  end
  xlabel('TIME [h]')
  if strcmp(signal,'delta1') || strcmp(signal,'delta2')  
    axis([0 45 0 UA+1000])
  end

  if strcmp(signal,'lactate')  % insets for lactate
    axis([0 45 0 40])
    axes('Position',[.82 .83 .05 .05])
    time_late= 38;  % time in hours to compute inset histogram 
    xbins_late=linspace(0,max(data(360*time_late-720:360*time_late+720)),30);
    [nlate,xlate]=hist(data(360*time_late-720:360*time_late+720),xbins);
    barh(xlate,nlate)
    box off
    axis([0 max(nlate) 0 30])
    axes('Position',[.5 .89 .05 .05])
    time_early= 8;  % time in hours to compute inset histogram 
    xbins_early=linspace(0,max(data(360*time_early-720:360*time_early+720)),30);
    [nearly,xearly]=hist(data(360*time_early-720:360*time_early+720),xbins);
    barh(xearly,nearly)
    box off
    axis([0 max(nearly) 0 30])
    hold off
  end
  bhand=gca;  
 % end of moving limits panel


% ----------------------------------------------------
% add a contour plot like panel d and add it to Figure
  if strcmp(signal,'delta1') || strcmp(signal,'delta2')
    tau_i=0.1:.1:5;  %1:.12:25
    tau_d=0.1:0.1:5; %0.1:.025:5
  end
  
  if strcmp(signal,'lactate')
tau_i=0.1:.05:3.8;
tau_d=0.005:.01:0.8;
    % tau_i=0.01:0.005:2*Ti;
    % tau_d=0.01:0.005:2*Td;
  end
  
  error=zeros(length(tau_i),length(tau_d));

% COMPUTING LOOP
% run the model and compute error for all combinations of tau_i and tau_d
for i=1:length(tau_i)
  for j=1:length(tau_d)
    S=run_S_model(PhysioVars,dt,(LA(1)+UA(1))/2,LA,UA,tau_i(i),tau_d(j),window_length,0,''); % run model
   
    % compute error 
    if strcmp(signal,'delta1') || strcmp(signal,'delta2')
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

% run one more time with the best tau values found from brute force
 if  strcmp(signal,'lactate')
    best_Sbf=run_S_model(PhysioVars,dt,(LA(1)+UA(1))/2,LA,UA,tau_i(r),tau_d(c),window_length,1,file(1).name);
  elseif strcmp(signal,'delta1') || strcmp(signal,'delta2')
    best_Sbf=run_S_model(PhysioVars,dt,(LA(1)+UA(1))/2,LA,UA,tau_i(r),tau_d(c),window_length,0,file(1).name);
  end

disp(['best tau_i found using brute force: ' num2str(tau_i(r))]);
disp(['best tau_d found using brute force: ' num2str(tau_d(c))]);

figure(F)
subplot(3,3,5:6)
 if strcmp(signal,'lactate')
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
    plot(tS,best_Sbf)   
    legend('wake','sleep','rem','best fit model')
    legend BOXOFF
    hold off
    xlabel('TIME [h]')
    ylabel('LACTATE SIGNAL [nA]')
    axis([0 45 0 40])
  elseif strcmp(signal,'delta1') || strcmp(signal,'delta2')
    scatter(t_mdpt_SWS,data_at_SWS_midpoints,30,'MarkerEdgeColor','k', ...
	    'LineWidth',1.5,'MarkerFaceColor',[0.5 0.5 0.5])
    hold on
    plot(t,best_Sbf,'k','LineWidth',1)
    ylabel('Delta power')
    xlabel('TIME [h]')
    axis([0 45 2000 6000])
    hold off
end


%figure
figure(F)
subplot(3,3,4)
[X,Y]=meshgrid(tau_d,tau_i);
%contour(X,Y,error,50,'LineColor',[0 0 0]);
contour(X,Y,error,50);
hold on
line([tau_d(c) tau_d(c)],[0 tau_i(r)],'LineStyle','--','Color',[0 0 0])
line([0 tau_d(c)],[tau_i(r) tau_i(r)],'LineStyle','--','Color',[0 0 0])
plot(tau_d(c),tau_i(r),'.','MarkerSize',5)
%plot(iters(:,1),iters(:,2),'x','MarkerSize',6) % plot the iterations of NM on contour
hold off
xlabel('Td [h]')
ylabel('Ti [h]')
if strcmp(signal,'delta1') || strcmp(signal,'delta2')
axis([tau_d(1) tau_d(end) tau_i(1) tau_i(end)])
end
if strcmp(signal,'lactate')
axis([tau_d(1) tau_d(end) tau_i(1) tau_i(end)])
end
chand=gca;
% -- End of contour plot code --

% -- Nelder-Mead iteration plot (triangles)
if strcmp(signal,'lactate')
  guesses=[0.5 1.5;0.7 1.5;0.6 0.5];
  [bti,btd,be,iters,xs,ys]=nelder_mead_for_lactate(guesses,1,1000,1e-9,1,PhysioVars,dt,LA,UA,window_length,mask);


elseif strcmp(signal,'delta1') || strcmp(signal,'delta2')
  guesses=[1 3; 3 3; 2 1];
  [bti,btd,be,iters,xs,ys]=nelder_mead_for_delta(guesses,1,1000,1e-9,1,PhysioVars,dt,LA,UA,t_mdpt_indices,data_at_SWS_midpoints);
end

figure(F)
subplot(3,3,7)
first_simplex=[guesses;guesses(1,:)];
plot(first_simplex(:,1),first_simplex(:,2),'-x')
hold on
for i=1:size(xs,1)
  xsl = [xs(i,:),xs(i,1)];
  ysl = [ys(i,:),ys(i,1)];
  plot(xs(i,:),ys(i,:),'or',xsl,ysl,'-k')
end
hold off


%plot(iters(:,1),iters(:,2),'x','MarkerSize',6)
if strcmp(signal,'delta1') || strcmp(signal,'delta2')
axis([tau_d(1) tau_d(end) tau_i(1) tau_i(end)])
end
if strcmp(signal,'lactate')
axis([tau_d(1) tau_d(end) tau_i(1) tau_i(end)])
end
xlabel('Td [h]')
ylabel('Ti [h]')
% ------------------------------------------




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
