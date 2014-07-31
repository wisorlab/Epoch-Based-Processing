

addpath ../../../../../../Brennecke/matlab-pipeline/Matlab/etc/matlab-utils/;
xl=XL('D:\mrempe\BL-118140Copy.txt');

sheet = xl.Sheets.Item(1);
[numcols,numrows] = xl.sheetSize(sheet)
xl.getCells(sheet,[1,1,1,100]);
xl.setCells(sheet,[2,3],[1:numrows-2]','FFEE00','true');
%xl.setCells(sheet,[1,1],[1:numrows]','FFEE00')
xl.saveAs('autoscored27.txt')

fclose('all')  %so Excel doesn't think MATLAB still has the file open