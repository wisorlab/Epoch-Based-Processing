clear  %clears all pre-existing variables from the workspace so they do not impact processing in this algorihtm.

%the user picks interval duration 

prompt = { 'This program reports sleep states W,N,R as a percent of each analysis interval and FFTs in equivalent intervals.  How many 10-sec epochs do you wish to include in each analysis interval? ' };
BinString = inputdlg(prompt,'Input',1,{'360'});
BinName=['% ' BinString  '-Epoch Interval'];
IntervalDuration = str2double( BinString{1,1} );

% look for 'matlab-utils' in the matlab folder
% addpath ../../../Matlab/etc/matlab-utils/;
addpath ../../../../Matlab/etc/matlab-utils/
addpath C:/Users/wisorlab/Documents/MATLAB/Brennecke/matlab-pipeline/Matlab/etc/matlab-utils;
addpath (pwd)

% create a new XL object
xl = XL;
xl.sourceInfo(mfilename('fullpath'));

xl.rmDefaultSheets();

% open the file dialog and get some '.txt' files
[files,path] = uigetfile({'*txt','Text Files (*.txt)';'*.*','All Files'; },'Select Data File(s)','MultiSelect','On');
if ischar(files), files = {files}; end

%following loop determines max number of intervals to be measured.  This
%dictates the size of cell arrays used to output data.
for FileCounter=1:length(files)  %this loop imports the data files one-by-one and processes the data in them into output files.
    combinedStr = strcat(path,files{FileCounter});
    importDSILactateFftfile(combinedStr);  %importfile is a function (stored as the file'importfile.m' that imports a DSI output text file to produce two matrices.
    % One matrix (textdata) holds the date/time stamp.  The other (data) holds the lactate and EEG data.
    %It is a major caveat that the headers from the txt file are retained in textdata but not in data, which means that data and textdata are not aligned with respect to epoch number
    
    numberIntervals(FileCounter) = fix(length(data)/IntervalDuration);
   
end

maxIntervals=max(numberIntervals);
NumberEEGColumns=20;

%Output arrays are created here.  They have one row for each file and one
%column for each anaylsis interval or analysis interval X EEG frequency
%bin.
OutputPctSWS = cell(length(files)+1,maxIntervals+1);
OutputPctWake= cell(length(files)+1,maxIntervals+1);
OutputPctREMS  = cell(length(files)+1,maxIntervals+1);
OutputSWA1=     cell(length(files)+1,maxIntervals+1);
OutputSWA2=     cell(length(files)+1,maxIntervals+1);
OutputEEG1SWS= cell(length(files)+1,maxIntervals*NumberEEGColumns+1);
OutputEEG1Wake= cell(length(files)+1,maxIntervals*NumberEEGColumns+1);
OutputEEG1REMS= cell(length(files)+1,maxIntervals*NumberEEGColumns+1);
OutputEEG2SWS= cell(length(files)+1,maxIntervals*NumberEEGColumns+1);
OutputEEG2Wake= cell(length(files)+1,maxIntervals*NumberEEGColumns+1);
OutputEEG2REMS= cell(length(files)+1,maxIntervals*NumberEEGColumns+1);


%Now count minutes of sleep and process FFT data.  These will be outputted
%on one line per file.

xl2 = XL;
sheetnames2 = {'WakeBoutCount','WakeBoutMean','SwsBoutCount','SwsBoutMean','RemsBoutCount','RemsBoutMean','BriefWakeCount'};
sheets2  = xl2.addSheets( sheetnames2 );
xl2.sourceInfo( mfilename('fullpath') );
xl2.rmDefaultSheets();


for FileCounter=1:length(files)  %this loop imports the data files one-by-one and processes the data in them into output files.
    combinedStr = strcat(path,files{FileCounter});
    importDSILactateFftfile(combinedStr);  %importfile is a function (stored as the file'importfile.m' that imports a DSI output text file to produce two matrices.
    % One matrix (textdata) holds the date/time stamp.  The other (data) holds the lactate and EEG data.
    %It is a major caveat that the headers from the txt file are retained in textdata but not in data, which means that data and textdata are not aligned with respect to epoch number
    numberIntervals(FileCounter)=(fix(length(data)/IntervalDuration));
    
     statechars=char(textdata(3:end,2));
    [WakeBoutCount(FileCounter,:),WakeBoutMean(FileCounter,:),SwsBoutCount(FileCounter,:),SwsBoutMean(FileCounter,:),RemsBoutCount(FileCounter,:),RemsBoutMean(FileCounter,:),BriefWakeCount(FileCounter,:)]=...
        DetectStateEpisodesIntervalMode(statechars,IntervalDuration);
    

    
    for k = 1:length(sheetnames2)
        xl2.setCells( sheets2{k}, [2,1],cellstr( num2str( (1:length(sheetnames2)+1)', [sheetnames2{k} '-%d']))');
        sheet = xl2.Sheets.Item( sheetnames2{k} );
        xl2.setCells( sheet, [1,FileCounter+1], [files{FileCounter}, num2cell(eval([ sheetnames2{k} '(FileCounter,:)']))]);
    end
   
    
    for BinReader = 1:numberIntervals(FileCounter)  %this loop initializes the three vectors that will ultimately sum up the power spectra (0-20 Hz in 1 Hz bins) for each state within the file.
        
        IntervalStart=(BinReader-1)*IntervalDuration+1;
        IntervalStop=IntervalStart+IntervalDuration-1;
        State=char(textdata(IntervalStart+2:IntervalStop+2,2));
        
        %here we ask whether there is a column of lactate data as column 1 of data.
        %If so, we account for that column in extracting EEG and EMG data.
        %Else, we assume EEG1 data are the very first column of data on.
        try 
            if textdata{2,3}=='[nA]' %nA is nanoamps, the units for lactate.
                RawLactate=data(1:end,1);
                [SmoothedLactatePercent(FileCounter),SmoothedLactate]=SmootheLactate(RawLactate);
                Lactate=SmoothedLactate(:,2);

               %'data' contains all numerical data.  Here, we extract the data of interest. 

                if  length(data(1,:))>80  %Do we have 40 1 Hz bins for each EEG channel? Where EEG2 data are located depends on this.
                    numhertz(FileCounter)=40;
                    EEG1fft=data(IntervalStart:IntervalStop,2:21);
                    EEG2fft=data(IntervalStart:IntervalStop,42:61);
                    EEG1slow=data(IntervalStart:IntervalStop,3:5);
                    EEG1swa=mean(EEG1slow,2);
                    EEG2slow=data(IntervalStart:IntervalStop,43:45);
                    EEG2swa=mean(EEG2slow,2);
                else
                    numhertz(FileCounter)=20;
                    EEG1fft=data(IntervalStart:IntervalStop,2:21);
                    EEG2fft=data(IntervalStart:IntervalStop,22:41);
                    EEG1slow=data(IntervalStart:IntervalStop,3:5);
                    EEG1swa=mean(EEG1slow,2);
                    EEG2slow=data(IntervalStart:IntervalStop,23:25);
                    EEG2swa=mean(EEG2slow,2);
                end
            end
        catch  %do the following if there is in fact no [na] column.
            if  length(data(1,:))>80
                numhertz(FileCounter)=40;
                EEG1fft=data(IntervalStart:IntervalStop,1:20);
                EEG2fft=data(IntervalStart:IntervalStop,41:60);
                EEG1slow=data(IntervalStart:IntervalStop,2:4);
                EEG1swa=mean(EEG1slow,2);
                EEG2slow=data(IntervalStart:IntervalStop,42:44);
                EEG2swa=mean(EEG2slow,2);
            else
                numhertz(FileCounter)=20;
                EEG1fft=data(IntervalStart:IntervalStop,1:20);
                EEG2fft=data(IntervalStart:IntervalStop,21:40);
                EEG1slow=data(IntervalStart:IntervalStop,2:4);
                EEG1swa=mean(EEG1slow,2);
                EEG2slow=data(IntervalStart:IntervalStop,22:24);
                EEG2swa=mean(EEG2slow,2);
            end
        end
        Emg=data(IntervalStart:IntervalStop,end);
        
      %here, we identify and count epochs of each state.
        
        SWSEpochs=find(logical(State=='S'));
        SWSMinutes(FileCounter,BinReader)=numel(SWSEpochs)/6;
        if SWSMinutes(FileCounter,BinReader)>0
            SWSEEG1FFT=EEG1fft(SWSEpochs(:),:);
            SWSEEG1Average(FileCounter,(BinReader-1)*20+1:(BinReader-1)*20+20)=mean(SWSEEG1FFT);
            SWSEEG2FFT=EEG2fft(SWSEpochs(:),:);
            SWSEEG2Average(FileCounter,(BinReader-1)*20+1:(BinReader-1)*20+20)=mean(SWSEEG2FFT);
            SWAEEG1Average(FileCounter,BinReader)=mean(EEG1swa(SWSEpochs(:)));
            SWAEEG2Average(FileCounter,BinReader)=mean(EEG2swa(SWSEpochs(:)));
        else
            SWAEEG1Average(FileCounter,BinReader)=NaN;
            SWAEEG2Average(FileCounter,BinReader)=NaN;
            SWSEEG1Average(FileCounter,(BinReader-1)*20+1:(BinReader-1)*20+20)=NaN;
            SWSEEG2Average(FileCounter,(BinReader-1)*20+1:(BinReader-1)*20+20)=NaN;
        end
        
        WakeEpochs=find(logical(State=='W' | State=='X'));
        WakeMinutes(FileCounter,BinReader)=numel(WakeEpochs)/6;
        if WakeMinutes(FileCounter,BinReader)>0
            WakeEEG1FFT=EEG1fft(WakeEpochs(:),:);
            WakeEEG1Average(FileCounter,(BinReader-1)*20+1:(BinReader-1)*20+20)=mean(WakeEEG1FFT);
            WakeEEG2FFT=EEG2fft(WakeEpochs(:),:);
            WakeEEG2Average(FileCounter,(BinReader-1)*20+1:(BinReader-1)*20+20)=mean(WakeEEG2FFT);
        else
            WakeEEG1Average(FileCounter,(BinReader-1)*20+1:(BinReader-1)*20+200)=NaN;
            WakeEEG2Average(FileCounter,(BinReader-1)*20+1:(BinReader-1)*20+200)=NaN;
        end
        
        REMSEpochs=find(logical(State=='R'));
        REMSMinutes(FileCounter,BinReader)=numel(REMSEpochs)/6;
        if REMSMinutes(FileCounter,BinReader)>0
            REMSEEG1FFT=EEG1fft(REMSEpochs(:),:);
            REMSEEG1Average(FileCounter,(BinReader-1)*20+1:(BinReader-1)*20+20)=mean(REMSEEG1FFT);
            REMSEEG2FFT=EEG2fft(REMSEpochs(:),:);
            REMSEEG2Average(FileCounter,(BinReader-1)*20+1:(BinReader-1)*20+20)=mean(REMSEEG2FFT);
        else
            REMSEEG1Average(FileCounter,(BinReader-1)*20+1:(BinReader-1)*20+20)=NaN;
            REMSEEG2Average(FileCounter,(BinReader-1)*20+1:(BinReader-1)*20+20)=NaN;
        end
        
    end
    
    
    %put data into cell arrays that will be placed in Excel Sheets.
    %the for loop is necessary because whole lines of numerical data cannot
    %be placed into a cell array chunk-wise.
    for IntervalCount=1:numberIntervals
        CellOutPctSWS  {FileCounter,IntervalCount} = SWSMinutes(FileCounter,IntervalCount);
        CellOutPctWake  {FileCounter,IntervalCount} = WakeMinutes(FileCounter,IntervalCount);
        CellOutPctREMS  {FileCounter,IntervalCount} = REMSMinutes(FileCounter,IntervalCount);
        CellOutSWA1  {FileCounter,IntervalCount} = SWAEEG1Average(FileCounter,IntervalCount);
        CellOutSWA2  {FileCounter,IntervalCount} = SWAEEG1Average(FileCounter,IntervalCount);
        
        for HertzCount=1:NumberEEGColumns
            CellOutEEG1SWS  {FileCounter,(IntervalCount-1)*NumberEEGColumns+HertzCount} = SWSEEG1Average(FileCounter,(IntervalCount-1)*NumberEEGColumns+HertzCount);
            CellOutEEG1Wake {FileCounter,(IntervalCount-1)*NumberEEGColumns+HertzCount} = WakeEEG1Average(FileCounter,(IntervalCount-1)*NumberEEGColumns+HertzCount);
            CellOutEEG1REMS {FileCounter,(IntervalCount-1)*NumberEEGColumns+HertzCount} = REMSEEG1Average(FileCounter,(IntervalCount-1)*NumberEEGColumns+HertzCount);
            CellOutEEG2SWS  {FileCounter,(IntervalCount-1)*NumberEEGColumns+HertzCount} = SWSEEG1Average(FileCounter,(IntervalCount-1)*NumberEEGColumns+HertzCount);
            CellOutEEG2Wake {FileCounter,(IntervalCount-1)*NumberEEGColumns+HertzCount} = WakeEEG1Average(FileCounter,(IntervalCount-1)*NumberEEGColumns+HertzCount);
            CellOutEEG2REMS {FileCounter,(IntervalCount-1)*NumberEEGColumns+HertzCount} = REMSEEG1Average(FileCounter,(IntervalCount-1)*NumberEEGColumns+HertzCount);
        end
    end
    
    %Concatenate Cell arrays line by line for each animal
    
    OutputPctSWS  (FileCounter+1,2:1+length(CellOutPctSWS(FileCounter,:))) = CellOutPctSWS(FileCounter,:);
    OutputPctWake (FileCounter+1,2:1+length(CellOutPctWake(FileCounter,:))) = CellOutPctWake(FileCounter,:);
    OutputPctREMS (FileCounter+1,2:1+length(CellOutPctREMS(FileCounter,:))) = CellOutPctREMS(FileCounter,:);
    OutputEEG1SWS (FileCounter+1,2:1+length(CellOutEEG1SWS(FileCounter,:))) = CellOutEEG1SWS(FileCounter,:);
    OutputEEG1Wake(FileCounter+1,2:1+length(CellOutEEG1Wake(FileCounter,:))) = CellOutEEG1Wake(FileCounter,:);
    OutputEEG1REMS(FileCounter+1,2:1+length(CellOutEEG1REMS(FileCounter,:))) = CellOutEEG1REMS(FileCounter,:);
    OutputEEG2SWS (FileCounter+1,2:1+length(CellOutEEG2SWS(FileCounter,:))) = CellOutEEG2SWS(FileCounter,:);
    OutputEEG2Wake(FileCounter+1,2:1+length(CellOutEEG2Wake(FileCounter,:))) = CellOutEEG2Wake(FileCounter,:);
    OutputEEG2REMS(FileCounter+1,2:1+length(CellOutEEG2REMS(FileCounter,:))) = CellOutEEG2REMS(FileCounter,:);
    OutputSWA1    (FileCounter+1,2:1+length(CellOutSWA1(FileCounter,:))) = CellOutSWA1(FileCounter,:);
    OutputSWA2    (FileCounter+1,2:1+length(CellOutSWA2(FileCounter,:))) = CellOutSWA2(FileCounter,:);
    
    OutPutEmg(FileCounter+1,1) = files(FileCounter);
    OutputSWA1(FileCounter+1,1) = files(FileCounter);
    OutputSWA2(FileCounter+1,1) = files(FileCounter);
    OutputEEG1SWS(FileCounter+1,1) = files(FileCounter);
    OutputEEG1Wake(FileCounter+1,1) = files(FileCounter);
    OutputEEG1REMS(FileCounter+1,1) = files(FileCounter);
    OutputEEG2SWS(FileCounter+1,1) = files(FileCounter);
    OutputEEG2Wake(FileCounter+1,1) = files(FileCounter);
    OutputEEG2REMS(FileCounter+1,1) = files(FileCounter);
    OutputPctSWS(FileCounter+1,1) = files(FileCounter);
    OutputPctWake(FileCounter+1,1) = files(FileCounter);
    OutputPctREMS(FileCounter+1,1) = files(FileCounter);
    
    
end

%label cell arrays

TextNote{1} = 'File ID';
OutputEmg(1,1) = TextNote(1);
OutputEEG1SWS(1,1) = TextNote(1);
OutputEEG1Wake(1,1) = TextNote(1);
OutputEEG1REMS(1,1) = TextNote(1);
OutputEEG2SWS(1,1) = TextNote(1);
OutputEEG2Wake(1,1) = TextNote(1);
OutputEEG2REMS(1,1) = TextNote(1);
OutputSWA1(1,1) = TextNote(1);
OutputSWA2(1,1) = TextNote(1);
OutputPctSWS(1,1) = TextNote(1);
OutputPctWake(1,1) = TextNote(1);
OutputPctREMS(1,1) = TextNote(1);
OutputPctSWS(1,2:maxIntervals+1) = MakeLabel ('SWS Minutes',maxIntervals);
OutputPctWake(1,2:maxIntervals+1) = MakeLabel ('Wake Minutes',maxIntervals);
OutputPctREMS(1,2:maxIntervals+1) = MakeLabel ('REMS Minutes',maxIntervals);
OutputEEG1SWS(1,2:(maxIntervals*NumberEEGColumns)+1) = MakeLabelHzBin ('SWS EEEG1',NumberEEGColumns,maxIntervals);
OutputEEG1Wake(1,2:(maxIntervals*NumberEEGColumns)+1) = MakeLabelHzBin ('Wake EEG1',NumberEEGColumns,maxIntervals);
OutputEEG1REMS(1,2:(maxIntervals*NumberEEGColumns)+1) = MakeLabelHzBin ('REMS EEG1',NumberEEGColumns,maxIntervals);
OutputEEG2SWS(1,2:(maxIntervals*NumberEEGColumns)+1) = MakeLabelHzBin ('SWS EEG2',NumberEEGColumns,maxIntervals);
OutputEEG2Wake(1,2:(maxIntervals*NumberEEGColumns)+1) = MakeLabelHzBin ('Wake EEG2',NumberEEGColumns,maxIntervals);
OutputEEG2REMS(1,2:(maxIntervals*NumberEEGColumns)+1) = MakeLabelHzBin ('REMS EEG2',NumberEEGColumns,maxIntervals);
OutputSWA1(1,2:maxIntervals+1) = MakeLabel ('SWS SWA 1',maxIntervals);
OutputSWA2(1,2:maxIntervals+1) = MakeLabel ('SWS SWA 2',maxIntervals);
OutPutEmg(1,2:maxIntervals+1) = MakeLabel ('Emg',maxIntervals);

%label output sheets
sheets1 = xl.addSheets({ 'SWS_Minutes' });
sheets2 = xl.addSheets({ 'REMS_Minutes' });
sheets3 = xl.addSheets({ 'Wake_Minutes' });
sheets4 = xl.addSheets({ 'EEG1 SWS FFT' });
sheets5 = xl.addSheets({ 'EEG1 SWA' });
sheets6= xl.addSheets({ 'EEG2 SWS FFT' });
sheets7= xl.addSheets({ 'EEG2 SWA' });
sheets8 = xl.addSheets({ 'EEG1 Wake FFT' });
sheets9 = xl.addSheets({ 'EEG2 Wake FFT' });
sheets10 = xl.addSheets({ 'EEG1 REMS FFT' });
sheets11 = xl.addSheets({ 'EEG2 REMS FFT' });

%insert cell arrays into output sheets
xl.setCells(  sheets1{1}, [1,1], [ OutputPctSWS ] );
xl.setCells( sheets2{1}, [1,1], [ OutputPctREMS ] );
xl.setCells( sheets3{1}, [1,1], [ OutputPctWake ] );
xl.setCells( sheets4{1}, [1,1], [ OutputEEG1SWS ] );
xl.setCells( sheets5{1}, [1,1], [ OutputSWA1 ] );
xl.setCells( sheets6{1}, [1,1], [ OutputEEG2SWS ] );
xl.setCells( sheets7{1}, [1,1], [ OutputSWA2 ] );
xl.setCells( sheets8{1}, [1,1], [ OutputEEG1Wake ] );
xl.setCells( sheets9{1}, [1,1], [ OutputEEG2Wake ] );
xl.setCells( sheets10{1}, [1,1], [ OutputEEG1REMS ] );
xl.setCells( sheets11{1}, [1,1], [ OutputEEG2REMS ] );

prompt = { 'This program reports sleep states W,N,R as a percent of each analysis interval and FFTs in equivalent intervals.  How many 10-sec epochs do you wish to include in each analysis interval? ' };
BinString = inputdlg(prompt,'Input',1,{'360'});

% create a header row with 'Data 1-72'
% TODO exchange 'data' for time... mod(10+(0:5:360)/60,12) or something
%next line replaces this: data = [ char(ones(72,1) * 'Data ' ) num2str( [1:72]' ) ];

%The first row of the line for this mouse within each matrix will identify the state from which the FFT data are derived.
load chirp
sound  (y)

prompt = { 'Would you like to add a notes section?' };
notes = questdlg(prompt);

if strcmpi(notes,'Yes')
    dataSourceSheet = xl2.Sheets.Item(1);
    xl.setCells(dataSourceSheet,[1,5],{'Notes','Please enter your notes here'})
end

xl.saveAs(['SleepPctFFT_' num2str(IntervalDuration) '-Epochs' ],path);
xl2.saveAs(['BoutAnalysis_' num2str(IntervalDuration) '-Epochs' ],path);



