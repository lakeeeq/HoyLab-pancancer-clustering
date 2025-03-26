% clearvars
clc

nFolder = 'results/';
load bigDataTable_altis.mat
[~,~,mrmInfo] = xlsread('20230208_ext.xlsx','altis_HILICz','A2:L28');
mrmInfo(find(strcmp(mrmInfo(:,1),'%%%%%')):end,:)  = [];

% nFolder = 'results_altis/';
% load bigDataTable_altis.mat
% [~,~,mrmInfo] = xlsread('20210420_GBM_13Cglc.xlsx','altis_HILICz','A2:L198');
% mrmInfo(find(strcmp(mrmInfo(:,1),'%%%%%')):end,:)  = [];

fileListR = dir(strcat([nFolder 'dataOut_*.mat']));
fid = fopen('results.txt','w');
fidSNR = fopen('snr.txt','w'); 
load(strcat([nFolder fileListR(1).name]));
tablePrint = zeros(size(mrmInfo,1),size(dataAligned,1)+1);

snrTable = tablePrint;
for i = 1:size(fileListR,1)
    load(strcat([nFolder fileListR(i).name]));
    hitRow = strcmp(mrmName,mrmInfo(:,1));
    tablePrint(hitRow,1) = RTpeak;
    tablePrint(hitRow,2:end) = dataOut;
    snrTable(hitRow,1) = RTpeak;
    snrTable(hitRow,2:end) = dataOut_stdev;
end

fprintf(fid,'\t\t');
for i = 1:size(fileList)
    fprintf(fid,'%s\t',fileList{i});
end
fprintf(fid,'\n');
for i = 1:size(mrmInfo,1)
    fprintf(fid,'%s\t',mrmInfo{i,1});
    fprintf(fid,'%1.3f\t',tablePrint(i,:));
    fprintf(fid,'\n');
    
    fprintf(fidSNR,'%s\t',mrmInfo{i,1});
    fprintf(fidSNR,'%1.3f\t',snrTable(i,:));
    fprintf(fidSNR,'\n');
end
fclose(fid);
fclose(fidSNR);
return