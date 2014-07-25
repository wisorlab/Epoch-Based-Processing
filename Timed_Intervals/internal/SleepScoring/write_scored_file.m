function write_scored_file(filename,predicted_score)
%
% Usage: write_scored_file(filename,predicted_score)
%
%
% This function simply replaces the sleep score column in 
% the file "filename" with the autoscore values generated from classify.m
% The result is written into a new file with the word AUTOSCORED in its name. 
%
% inputs:
% filename           .txt file from which we are overwriting the sleep state info, but keeping everything else
% predicted_score    the output of classify.m generated in classify_usingPCA.m


% This is so I can use Jon's stuff 
addpath ../../../../../../Brennecke/matlab-pipeline/Matlab/etc/matlab-utils/;
%xl=XL('D:\mrempe\BL-118140Copy.txt');
xl=XL(filename);

sheet = xl.Sheets.Item(1);
[numcols,numrows] = xl.sheetSize(sheet)
%xl.getCells(sheet,[1,1,1,100]);
xl.setCells(sheet,[2,3],predicted_score,'FFEE00','true');
a=find(filename=='.');
xl.saveAs(strcat(filename(1:a),'AUTOSCORED','.txt'));
%xl.saveAs('anothertest.txt')

fclose('all')  %so Excel doesn't think MATLAB still has the file open