function [Feature,PCAvectors]=sleepscorePCA(inputfile,signal,outputfilename)

	% This function uses Principal Component Analysis (PCA) to automatically
	% score a sleep data set (following Gilmour et al 2010)

	% INPUT:
	% inputfile		a .txt file where the EEG and EMG data have been partitioned into frequency bins
	%				and each row represents an average over an epoch (10 seconds, 4 seconds, etc.)
	%				For now I'm assuming that this .txt file has the following columns: 
	%				TimeStamp	SleepState	Lactate	EEG1	EEG1 ... EEG2	EEG2 ... EMG
	%
	% signal			either EEG1 or EEG2 specifying which signal to use
	% outputfilename 	the name of the file to which the Feature Matrix and PCA vectors are written  
	 

	% TODO:
	% Make a snazzy user interface so you can just click on data points plotted along the principal 
	% component axes and that will add the correct sleep state (W, S, or R) to the data file. 
	% check into using gname.m 





	% First, read in the .txt file 
	% data has columns: lactate, EEG1_0.5-1Hz, EEG1_1-2Hz etc.
	[data,textdata]=importdatafile(inputfile);


% Set up the feature matrix, a la Gilmour.
% rows are data points, columns are delta	theta	low beta	high beta	EMG	Theta/delta	Beta/delta 
% where delta = 1-4 Hz
% 		theta = 5-9 Hz
%		low beta = 10-20 Hz
%		high beta = 30-40 Hz
%		Theta/delta is the ratio of theta to delta
%		Beta/delta is the ratio of beta to delta (here beta is defined as 15-30Hz)

if strcmp(signal,'EEG1')
	Feature(:,1) = mean(data(:,3:5),2);	%delta
	Feature(:,2) = mean(data(:,7:10),2);	%theta
	Feature(:,3) = mean(data(:,12:21),2);	%low beta
	Feature(:,4) = mean(data(:,32:41),2);	%high beta
	Feature(:,5) = data(:,82);				%EMG
	Feature(:,6) = Feature(:,2)./Feature(:,1);
	Feature(:,7) = mean(data(:,17:31),2)./Feature(:,1);
end 

if strcmp(signal,'EEG2')  
	Feature(:,1) = mean(data(:,43:45),2);	%delta
	Feature(:,2) = mean(data(:,47:50),2);	%theta
	Feature(:,3) = mean(data(:,52:61),2);	%low beta
	Feature(:,4) = mean(data(:,72:81),2);	%high beta
	Feature(:,5) = data(:,82);				%EMG
	Feature(:,6) = Feature(:,2)./Feature(:,1);
	Feature(:,7) = mean(data(:,57:71),2)./Feature(:,1);
end


% Finally, do the PCA (using svd, the default for pca.m) 
% First normalize so each variable goes from -1 to 1.  This seems to be what Gilmour_etal did (Fig 1)
scalefactor = max(max(Feature))-min(min(Feature));
[Coeff,FeaturesPCA,latent,tsquared,explained]=pca((2*(Feature-max(max(Feature))))./scalefactor+1);
explained

% Now plot the points along the three eigenvectors with the 3 
% largest eigenvalues of the covariance matrix
figure
plot3(FeaturesPCA(:,1),FeaturesPCA(:,2),FeaturesPCA(:,3),'.')
xlabel('PC1')
ylabel('PC2')
zlabel('PC3')
title(inputfile)

figure %plot delta vs. EMG
plot(Feature(:,5)./max(Feature(:,5)),Feature(:,1)./max(Feature(:,1)),'.') %normalize 
xlabel('EMG Power')
ylabel('EEG delta Power')

% figure
% plot3(score2(:,1),score2(:,2),score2(:,3),'.')
% xlabel('PC1')
% ylabel('PC2')
% zlabel('PC3')


% Try it again using eigs
%  tic
%  k=3;   % number of principal compenents to keep
%  C=Feature*Feature';    % covariance matrix
%  disp(['The Covariance matrix is ', num2str(size(C,1)), ' by ', num2str(size(C,2))])
%  [W,L]=eigs(C,k);    %compute the k largest eigenvalues/eigenvectors
%  Wt=W';
%  Y=Wt*Feature;
% FeaturesPCA = W*Y;  %FeaturesPCA contains the same number of observations as Features, but only k columns
% % 	                       % The columns of FeaturesPCA are the first k principal components.
%  figure
%  plot3(FeaturesPCA(:,1),FeaturesPCA(:,2),FeaturesPCA(:,3),'.')
%  xlabel('PC1')
%  ylabel('PC2')
%  zlabel('PC3')
% title('Using eigs, no normalizing')

% toc

%Try it a third way, normalizing the data first
%and using svd.  (This is too slow so I abandoned it)
% k=3;   % number of principal compenents to keep
% [m,n]=size(Feature);
% mnFeature = mean(Feature,2);   % row mean
% X = Feature - repmat(mnFeature,1,n);  % subtract row mean
% Z = 1/sqrt(n-1)*X';   %
% C=Z'*Z;    % covariance matrix
% [U,S,V] = svd(C);
% VV=V(:,1:k);
% Y=VV'*X;
% XX=VV*Y;
% XX=XX+repmat(mn,1,n);  %add row means back on


%tic
% Try it using eigs, but also normalizing first
% k=3;   % number of principal compenents to keep
% [m,n]=size(Feature);
% mnFeature = mean(Feature,2);   % row mean
% X = Feature - repmat(mnFeature,1,n);  % subtract row mean
% X = 2/(max(max(X))-min(min(X))).*(X-max(max(X)))+1; %normalize so -1<=X<=1
% Z = 1/sqrt(n-1)*X';   %
% C2=Z'*Z;    % covariance matrix
% [W2,L2]=eigs(C2,k);    %compute the k largest eigenvalues/eigenvectors
%  %Wt2=W2';
%  Y=W2'*X;
% FeaturesPCAnormed = W2*Y;
%FeaturesPCAnormed = FeaturesPCAnormed + repmat(mnFeature,1,n); %add row means back in
% figure
% plot3(FeaturesPCAnormed(:,1),FeaturesPCAnormed(:,2),FeaturesPCAnormed(:,3),'.')
% xlabel('PC1')
% ylabel('PC2')
% zlabel('PC3')
% title('Using eigs, subtracting row mean, normalizing (not adding row means back in)')
% toc

PCAvectors = FeaturesPCA;


% Make a plot of all the vectors together in subplots
figure
t=linspace(0,(1/360)*size(Feature,1),size(Feature,1));
subplot(10,1,1)
plot(t,PCAvectors(:,1),'r')
ylabel('PCA 1')
set(gca,'YTickLabel',[])
set(gca,'YTick',[])
set(gca,'XTickLabel',[])
set(gca,'XTick',[])
box off
set(get(gca,'YLabel'),'Rotation',0)
set(get(gca,'YLabel'),'HorizontalAlignment','right')

subplot(10,1,2)
plot(t,PCAvectors(:,2),'g')
ylabel('PCA 2')
set(gca,'YTickLabel',[])
set(gca,'YTick',[])
set(gca,'XTickLabel',[])
set(gca,'XTick',[])
box off
set(get(gca,'YLabel'),'Rotation',0)
set(get(gca,'YLabel'),'HorizontalAlignment','right')

subplot(10,1,3)
plot(t,PCAvectors(:,3),'b')
ylabel('PCA 3')
set(gca,'YTickLabel',[])
set(gca,'YTick',[])
set(gca,'XTickLabel',[])
set(gca,'XTick',[])
box off
set(get(gca,'YLabel'),'Rotation',0)
set(get(gca,'YLabel'),'HorizontalAlignment','right')

subplot(10,1,4)
plot(t,Feature(:,7),'k')
ylabel('Beta/Delta')
set(gca,'YTickLabel',[])
set(gca,'YTick',[])
set(gca,'XTickLabel',[])
set(gca,'XTick',[])
box off
set(get(gca,'YLabel'),'Rotation',0)
set(get(gca,'YLabel'),'HorizontalAlignment','right')

subplot(10,1,5)
plot(t,Feature(:,6),'k')
ylabel('Theta/Delta')
set(gca,'YTickLabel',[])
set(gca,'YTick',[])
set(gca,'XTickLabel',[])
set(gca,'XTick',[])
box off
set(get(gca,'YLabel'),'Rotation',0)
set(get(gca,'YLabel'),'HorizontalAlignment','right')

subplot(10,1,6)
plot(t,Feature(:,5),'k')
ylabel('EMG')
set(gca,'YTickLabel',[])
set(gca,'YTick',[])
set(gca,'XTickLabel',[])
set(gca,'XTick',[])
box off
set(get(gca,'YLabel'),'Rotation',0)
set(get(gca,'YLabel'),'HorizontalAlignment','right')

subplot(10,1,7)
plot(t,Feature(:,4),'k')
ylabel('High Beta')
set(gca,'YTickLabel',[])
set(gca,'YTick',[])
set(gca,'XTickLabel',[])
set(gca,'XTick',[])
box off
set(get(gca,'YLabel'),'Rotation',0)
set(get(gca,'YLabel'),'HorizontalAlignment','right')

subplot(10,1,8)
plot(t,Feature(:,3),'k')
ylabel('Low Beta')
set(gca,'YTickLabel',[])
set(gca,'YTick',[])
set(gca,'XTickLabel',[])
set(gca,'XTick',[])
box off
set(get(gca,'YLabel'),'Rotation',0)
set(get(gca,'YLabel'),'HorizontalAlignment','right')

subplot(10,1,9)
plot(t,Feature(:,2),'k')
ylabel('Theta')
set(gca,'YTickLabel',[])
set(gca,'YTick',[])
set(gca,'XTickLabel',[])
set(gca,'XTick',[])
box off
set(get(gca,'YLabel'),'Rotation',0)
set(get(gca,'YLabel'),'HorizontalAlignment','right')

subplot(10,1,10)
plot(t,Feature(:,1),'k')
ylabel('Delta')
set(gca,'YTickLabel',[])
set(gca,'YTick',[])
box off
set(get(gca,'YLabel'),'Rotation',0)
set(get(gca,'YLabel'),'HorizontalAlignment','right')

% remove white space in-between plots by expanding each subplot (I stole this)
nF=1.3;  % factor to scale by
hAx = findobj(gcf, 'type', 'axes');
for h = 1:length(hAx)
    vCurrPos = get(hAx(h), 'position'); % current position
    set(hAx(h), 'position', (vCurrPos.*[1 1 1 nF])-[0 vCurrPos(4)*(nF-1)/2 0 0]);
end
    %set(hAx(h), 'position', (vCurrPos.*[1 1 nF nF])-[vCurrPos(3)*(nF-1)/2 vCurrPos(4)*(nF-1)/2 0 0]);


%Finally, write out the tab-delimited PCA data as well as the Feature matrix
% Rows are data points, Cols are Organized as follows: Delta	Theta	LowBeta	HighBeta	EMG	Theta/Delta	Beta/Delta	PCA1	PCA2 etc.
dlmwrite(outputfilename,[Feature PCAvectors],'delimiter','\t')

