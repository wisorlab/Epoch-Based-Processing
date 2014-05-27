% This script calls ProcessLBatchMode.m to compute the taui
% and taud values (rise and fall time constants) for 
% delta power and for lactate for all the strains of mice 
% in the strain study (AKR, BA, BL, DBA).  Then it makes
% a figure with bar graphs for each varaiable. (total of 6 bar graphs)


% these are the directories where the data are stored:
AKR_path = 'D:/mrempe/strain_study_data/AKR/long_files/concat/';
BA_path  = 'D:/mrempe/strain_study_data/BA/BA_long/';
BL_path  = 'D:/mrempe/strain_study_data/BL/long_files/';
DBA_path = 'D:/mrempe/strain_study_data/DBA/long_files/';


% Call ProcessLBatchMode.m for each strain for lactate and delta
% first delta
[signaAKRd,stateAKRd,SAKRd,TiAKRd,TdAKRd]=PROCESSLBATCHMODE(AKR_path,'delta1');
[signaBAd,stateBAd,SBAd,TiBAd,TdBAd]=PROCESSLBATCHMODE(BA_path,'delta1');
[signaBLd,stateBLd,SBLd,TiBLd,TdBLd]=PROCESSLBATCHMODE(BL_path,'delta1');
[signaDBAd,stateDBAd,SDBAd,TiDBAd,TdDBAd]=PROCESSLBATCHMODE(DBA_path,'delta1');

% then lactate
[signaAKR,stateAKR,SAKR,TiAKR,TdAKR]=PROCESSLBATCHMODE(AKR_path,'lactate');
[signaBA,stateBA,SBA,TiBA,TdBA]=PROCESSLBATCHMODE(BA_path,'lactate');
[signaBL,stateBL,SBL,TiBL,TdBL]=PROCESSLBATCHMODE(BL_path,'lactate');
[signaDBA,stateDBA,SDBA,TiDBA,TdDBA]=PROCESSLBATCHMODE(DBA_path,'lactate');


% Now compute averages for the taui values
average_taui_lactate = [mean(TiBA) mean(TiAKR) mean(TiBL) mean(TiDBA)];
average_taui_delta   = [mean(TiBAd) mean(TiAKRd) mean(TiBLd) mean(TiDBAd)];

% same for taud values
average_taud_lactate = [mean(TdBA) mean(TdAKR) mean(TdBL) mean(TdDBA)];
average_taud_delta   = [mean(TdBAd) mean(TdAKRd) mean(TdBLd) mean(TdDBAd)];

% compute SEM for taui values
SEM_taui_lactate = [nansem(TiBA) nansem(TiAKR) nansem(TiBL) nansem(TiDBA)];
SEM_taui_delta   = [nansem(TiBAd) nansem(TiAKRd) nansem(TiBLd) nansem(TiDBAd)];

% compute SEM for taud values
SEM_taud_lactate = [nansem(TdBA) nansem(TdAKR) nansem(TdBL) nansem(TdDBA)];
SEM_taud_delta   = [nansem(TdBAd) nansem(TdAKRd) nansem(TdBLd) nansem(TdDBAd)];


% Franken data (to plot and compare to)
Franken_taui = [7.6 5.3 8 12.6];
Franken_taud = [1.6 1.9 1.8 1.8];
Franken_SEM_taui = [1.1 0.3 0.5 1.6];
Franken_SEM_taud = [0.2 0.1 0.2 0.3];


% Finally, make the plot
figure
subplot(5,3,[1:3:10])
bar(1:4,average_taui_lactate)
hold on
h=errorbar(1:4,average_taui_lactate,SEM_taui_lactate)
errorbar_tick(h,0)
hold off
ylabel('\tau_i (hrs)')

subplot(5,3,[2:3:11])
bar(1:4,average_taui_delta)
hold on
h=errorbar(1:4,average_taui_delta,SEM_taui_delta)
errorbar_tick(h,0)
hold off

subplot(5,3,[3:3:12])
bar(1:4,Franken_taui)
hold on
h=errorbar(1:4,Franken_taui,Franken_SEM_taui)
errorbar_tick(h,0)
hold off

subplot(5,3,13)
bar(1:4,average_taud_lactate)
hold on
h=errorbar(1:4,average_taud_lactate,SEM_taud_lactate)
errorbar_tick(h,0)
ylabel('\tau_d (hrs)')
hold off

subplot(5,3,14)
bar(1:4,average_taud_delta)
hold on
h=errorbar(1:4,average_taud_delta,SEM_taud_delta)
errorbar_tick(h,0)
hold off

subplot(5,3,15)
bar(1:4,Franken_taud)
hold on
h=errorbar(1:4,Franken_taud,Franken_SEM_taud)
errorbar_tick(h,0)
hold off


