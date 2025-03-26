function runner_altis(xx,extractTrue)

%{
for i = 1:numel(metNames)
runner_altis(i,true);
end
%}

if nargin <= 1
    extractTrue = false;
end
if nargin < 1
    xx = input('specify metabolite name or index>','s');
    yy = str2num(xx);
    if ~isempty(yy)
        xx = yy;
        end
end

clc
clf
addpath ./fxn
% xx = 4;
% extractTrue = true;
% %{
if xx == -1
    folderName = '8_2_23_altisn3mzml';
    fileList = dir(strcat([folderName '/*.mzML']));
    bigDataTable = struct([]);
    for i = 1:length(fileList)
        disp(fileList(i).name);
        fileInputName = strcat([folderName,'/',fileList(i).name]);
        %     tic
        [bigDataTable(i).fileReadName,bigDataTable(i).startTimeStamp,bigDataTable(i).scanOutput] = readmzML_altisSRM(fileInputName);
        bigDataTable(i).fileReadName = fileList(i).name;
        %     toc
        
    end
    
    [~,index] = sort({bigDataTable.startTimeStamp});
    bigDataTable = bigDataTable(index);
    save bigDataTable_altis bigDataTable
    
    
    %%%%clean up periodic zeros in acquisition%%%%
    %%%randomly sample  blocks of 10, 100 times
    %%%compile corrections needed
    corrNeeded = [];
    for i = 1:size(bigDataTable,2)
        soCopy = bigDataTable(i).scanOutput;
        for j = 1:size(soCopy,1)
            intVect = soCopy{j,6};
            hitZero = intVect == 0;
            zeroFract = sum(hitZero)/numel(intVect);
            if zeroFract>0.4 && zeroFract<0.6
                hzDist = zeros(100,1);
                for kk = 1:100
                    startI = randi(numel(intVect)-10);
                    intVectSeg = intVect(startI:startI+9);
                    hzDist(kk) = sum(intVectSeg==0);
                end
                if numel(unique(hzDist))<=5
                    corrNeeded(end+1,:) = [i j zeroFract]
                end
            end
        end
    end
%     mrmToCorrect = 35;meanPoints = 5;
%     for i = 1:size(bigDataTable,2)
%         bigDataTable(i).scanOutput{mrmToCorrect,6} = movmean(bigDataTable(i).scanOutput{mrmToCorrect,6},meanPoints);
%     end
return
end



%}

%%%%%edit here%%%%
peakThreshold = 0.005;
load bigDataTable_altis.mat
[~,~,mrmInfo] = xlsread('20230208_ext.xlsx','altis_HILICz','A2:L28');
mrmInfo(find(strcmp(mrmInfo(:,1),'%%%%%')):end,:)  = [];
tsFileName = 'timeShiftTable_altis.mat';
%{
timeShiftTable = cell(0,4);save(tsFileName,'timeShiftTable');

save(axHistShow.tsFileName, 'timeShiftTable');
%}




% rowPickTable = {
%     [1	181:184	186:191	267]%blanks
%     [2 3 55 129 185 265]%stds
%     [4 5 54 128 130 192 266]%pool
%      [1	6:11 51:53 125:127 131:134 193:196 261:264]%T0
%     [12:50 56:124 135:180 197:260]%samples
% };

rowPickTable = {
    [1 2 84:90 96 146 218 219]%blanks
    [3 4 48 85 88 91 97 147 216]%stds
    [5 6 49 92 98 148 217]%pool
     [7:15 78:83 93:95 143:145 213:214]%T0
    [16:47 50:77 99:142 149:212]%samples
};


%rowList_altis

isQTRAP = false;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if isQTRAP
    mrmColIndx = [1 2 3 9 10 11 12 5];%%%grp name, q1,q3,mode,rt,lb,ub, mrmName %%for qtrap
else
    mrmColIndx = [1 6 7 5 10 11 12 2];%%%grp name, q1,q3,mode,rt,lb,ub, mrmName %%for altis
end


%%%steps%%%%
%%%make TIC based on grp name, align, t hen integrate%%
[metNames index] = unique(mrmInfo(:,mrmColIndx(1)));
[~,sIndex] = sort(index);
metNames = metNames(sIndex);

%%%%%%%%%%%%%%%%%%


fileList = {};
fileGrp = [];
rowPickTable_list = [];
for i = 1:numel(rowPickTable)
    for j = 1:numel(rowPickTable{i})
        %         fileGrp(end+1) = grpColor(i);
        fileGrp(end+1) = i;
        fileList{end+1,1} = bigDataTable(rowPickTable{i}(j)).fileReadName;
        rowPickTable_list(end+1) = rowPickTable{i}(j);
    end
end

figure(1)

if ischar(xx)
    ii = find(strcmp(xx,metNames));
else
    ii = xx;
end
if isempty(ii) || ii > size(metNames,1) || ii<1
    disp('no met match or exceed index');
    return
end


hitMRMs = strcmp(metNames{ii},mrmInfo(:,mrmColIndx(1)));
mrmInfoSub = mrmInfo(hitMRMs,mrmColIndx(1:3));
mrmNameInfo = mrmInfo(hitMRMs,mrmColIndx(8));
firstRow = find(hitMRMs,1,'first');
mrmName = metNames{ii};

disp([num2str(ii) '. ' mrmName])
ticMat = [];
mrmMat = [];
timeMat = [];

clf
subplot(4,4,1:2);

for k = 1:size(rowPickTable,1)
    rowPick = rowPickTable{k};
    for i = rowPick
        infoMatrix = cell2mat(bigDataTable(i).scanOutput(:,[3 4]));
        hitRows = false(size(infoMatrix,1),1);
        hitRowsSeq = zeros(size(hitRows));
        for j = find(hitMRMs)'
            q1 = mrmInfo{j,mrmColIndx(2)};
            q3 = mrmInfo{j,mrmColIndx(3)};
            newRow = abs(infoMatrix(:,1)-q1)<0.001 &...
                abs(infoMatrix(:,2)-q3)<0.001;
            if sum(newRow)>1
                disp('more than one MRM matched')
            end
            if sum(newRow)==0
                disp('no MRM matched')
            end
            hitRows(find(newRow,1,'first')) = true;
            hitRowsSeq(find(newRow,1,'first')) = j;
        end
        hitRowsSeq = hitRowsSeq(hitRows);
        [~,index] = sort(hitRowsSeq);
        hitRows = find(hitRows)'+1;
        hitRows = hitRows(index);
        %%%map time line within cluster to smallest time
        smallestTime = numel(bigDataTable(i).scanOutput{hitRows(1),5});
        hitIndex = hitRows(1);
        for j = 2:numel(hitRows)
            if numel(bigDataTable(i).scanOutput{hitRows(j),5}) < smallestTime
                smallestTime = numel(bigDataTable(i).scanOutput{hitRows(j),5});
                hitIndex = hitRows(j);
            end
        end
        timeVect = bigDataTable(i).scanOutput{hitIndex,5};
        intVect = zeros(numel(hitRows),numel(timeVect));
        
        
        for j = 1:numel(hitRows)
            intLine = bigDataTable(i).scanOutput{hitRows(j),6};
            timeLine = bigDataTable(i).scanOutput{hitRows(j),5};
            timeDiffMin = inf(1,numel(timeVect));
            assignIdx = zeros(1,numel(timeVect));
            for j2 = 1:numel(timeLine)
                [minDiff,indexMin] = min(abs(timeVect-timeLine(j2)));
                if timeDiffMin(indexMin)>minDiff
                    timeDiffMin(indexMin) = minDiff;
                    assignIdx(indexMin) = j2;
                end
            end
            intVect(j,assignIdx~=0) = intLine(assignIdx(assignIdx~=0));
        end
        % single time line, based on first time. gaps are not uniform (scheduled mrm)
        % the actual time is consistent down to 1s (2nd decimal in minutes)
        timeMat{end+1,1} = timeVect;
        mrmMat{end+1,1} = intVect;
        ticMat{end+1,1} = sum(intVect,1);
    end
end

noDat = size(ticMat,1);
datIndex = 1:noDat;
placeCard = 1;
for i = 1:numel(rowPickTable)
    datIndex(fileGrp==i) = datIndex(fileGrp==i) + 10*(i-1);
    placeCard(end+1) = datIndex(find(fileGrp==i,1,'last'));
end
hold on
for i = 1:noDat
    plot3(timeMat{i},datIndex(i)*ones(size(timeMat{i})),ticMat{i},'-');
end
hold off
view([-15 30]);
title(metNames{ii});

%%%generate a common time vector and
%remap datapoints to the first smallest time vector by linear interpolation
smallestTime = numel(timeMat{1});
timeRepVect = timeMat{1};
for i = 2:noDat
    if numel(timeMat{i}) < smallestTime
        smallestTime = numel(timeMat{i});
        timeRepVect = timeMat{i};
    end
end

%%%interpolating to display, but integrate original track
intMat = zeros(noDat,numel(timeRepVect));
for i = 1:noDat
    intMat(i,:) = interp1(timeMat{i},ticMat{i},timeRepVect);
end

RTchoose = mrmInfo{firstRow,mrmColIndx(5)};

load(tsFileName);
hitRow = strcmp(mrmName,timeShiftTable(:,1));
if isempty(timeShiftTable) || ~any(hitRow)
    RTwindow = [1 1];
else
    RTwindow = timeShiftTable{hitRow,4};
end
%%%%%CHANGE%%%%
startTime = RTchoose-RTwindow(1);
stopTime = RTchoose+RTwindow(2);
%use acquisition window if smaller than RT window
if sum(timeRepVect<startTime)<5
    startTime = timeRepVect(6);
end
if sum(timeRepVect>stopTime)<5
    stopTime = timeRepVect(end-5);
end


hold on
for i = 1:numel(placeCard)
    plot3([RTchoose RTchoose],[placeCard(i) placeCard(i)],[0 max(max(intMat))],'k--','LineWidth',2);
end
hold off

subplot(4,4,3:4);
plotDataIntoPatch(intMat,timeRepVect,fileGrp);
pp1 = gca;

hold on
plot([startTime startTime],pp1.YLim,'m-');
plot([stopTime stopTime],pp1.YLim,'m-');
plot([RTchoose RTchoose],pp1.YLim,'k--','LineWidth',2);
hold off


%%%skip alignment due to low sample sensitivity%%%
notShift = true;
[timeShift, dataAligned, timeWindow] = alignPeaks_TS(timeRepVect,intMat,startTime,stopTime,...
    timeShiftTable, mrmName,rowPickTable,notShift);
tsCell = [num2cell(timeShift') fileList];

timeShift = cell2mat(tsCell(:,1))';
timeShiftTable = saveTimeShiftRT(timeShiftTable,mrmName,timeShift,rowPickTable,tsFileName,RTwindow);


subplot(4,4,5:12);
axHist = plotDataIntoPatch2(dataAligned,timeWindow,fileGrp);
axHist.metIndex = ii;
axHist.scriptName = mfilename;
axHist.timeShiftTable = timeShiftTable;
axHist.mrmName = mrmName;
axHist.mrmNameInfo = regexprep(mrmNameInfo,'_','\\_');
axHist.timeShift = timeShift;
axHist.rowPickTable = rowPickTable;
axHist.tsFileName = tsFileName;
axHist.mrmInfo = mrmInfoSub;
axHist.mrmMat = mrmMat;
axHist.timeMat = timeMat;
axHist.RTchoose = RTchoose;
axHist.RTwindow = RTwindow;

axHist.fileList = regexprep(fileList,'_','\\_');
set(axHist.f_handle,'KeyPressFcn',@(src,evt)myhotkey1p(src,evt,axHist),'KeyReleaseFcn',@(src,evt)myhotkey1r(src,evt,axHist),...
    'WindowButtonMotionFcn','');

btn1 = uicontrol('Style', 'pushbutton', 'String', 'Reload','Units','normalized','Position',[0.0253 0.0235 0.0759 0.0247],...
    'Callback',@(hObject, eventdata)reloadFig(hObject, eventdata,axHist));
btn2 = uicontrol('Style', 'pushbutton', 'String', 'Save','Units','normalized','Position',[0.1253 0.0235 0.0759 0.0247],...
    'Callback',@(hObject, eventdata)reloadFig(hObject, eventdata,axHist));
btn3 = uicontrol('Style', 'pushbutton', 'String', 'Previous','Units','normalized','Position',[0.2253 0.0235 0.0759 0.0247],...
    'Callback',@(hObject, eventdata)reloadFig(hObject, eventdata,axHist));
btn4 = uicontrol('Style', 'pushbutton', 'String', 'Next','Units','normalized','Position',[0.3253 0.0235 0.0759 0.0247],...
    'Callback',@(hObject, eventdata)reloadFig(hObject, eventdata,axHist));
btn5 = uicontrol('Style', 'pushbutton', 'String', 'Realign','Units','normalized','Position',[0.4253 0.0235 0.0759 0.0247],...
    'Callback',@(hObject, eventdata)reloadFig(hObject, eventdata,axHist));
btn6 = uicontrol('Style', 'pushbutton', 'String', 'Sav & Int','Units','normalized','Position',[0.5253 0.0235 0.0759 0.0247],...
    'Callback',@(hObject, eventdata)reloadFig(hObject, eventdata,axHist));
edt1 = uicontrol('Style', 'edit','Tag','lhs', 'String', num2str(RTwindow(1)),'Units','normalized','Position',[0.6253 0.0235 0.03 0.0247],...
    'Callback',@(hObject, eventdata)editbox_Callback(hObject, eventdata,axHist));
edt2 = uicontrol('Style', 'edit','Tag','rhs', 'String', num2str(RTwindow(2)),'Units','normalized','Position',[0.6753 0.0235 0.03 0.0247],...
    'Callback',@(hObject, eventdata)editbox_Callback(hObject, eventdata,axHist));

assignin('base','axHistShow',axHist);
assignin('base','bigDataTable',bigDataTable);
assignin('base','metNames',metNames);
assignin('base','timeShiftTable',axHist.timeShiftTable);

%%%%%%%%%%get sum signal boundary%%%%%%%%%%%
TIC = sum(dataAligned,1)';

[~,index] = min(abs([timeWindow - RTchoose]));
if mrmInfo{firstRow,mrmColIndx(6)} == 0 && mrmInfo{firstRow,mrmColIndx(7)} ==0
    hitSig_out = opBoundaries(TIC, index,peakThreshold);
    bgPoints = false(size(hitSig_out));
    bgStopper = [];
elseif mrmInfo{firstRow,mrmColIndx(6)} == 0 && mrmInfo{firstRow,mrmColIndx(7)} ~=0
    hitSig_out = opBoundaries(TIC, index,peakThreshold);
    if ~any(hitSig_out)
        hitSig_out(index-1:index+1) = true;
    end
    hitSig_out_copy = false(size(hitSig_out));
    hitSig_out_copy(find(hitSig_out,1,'first'):end) = true;
    hitSig_out = hitSig_out_copy & timeWindow'<= mrmInfo{firstRow,mrmColIndx(7)};
    bgPoints = false(size(hitSig_out));
    bgPoints(find(hitSig_out,1,'last')+1) = true;    
    bgStopper = 1;%on the right
elseif mrmInfo{firstRow,mrmColIndx(6)} ~= 0 && mrmInfo{firstRow,mrmColIndx(7)} ==0
    hitSig_out = opBoundaries(TIC, index,peakThreshold);
    hitSig_out_copy = false(size(hitSig_out));
    hitSig_out_copy(1:find(hitSig_out,1,'last')) = true;
    hitSig_out = hitSig_out_copy & timeWindow'>= mrmInfo{firstRow,mrmColIndx(6)};
    bgPoints = false(size(hitSig_out));
    bgPoints(find(hitSig_out,1,'first')-1) = true;  
    bgStopper = -1;%on the left
    
elseif mrmInfo{firstRow,mrmColIndx(6)} ~= 0 && mrmInfo{firstRow,mrmColIndx(7)} ~=0
    hitSig_out = timeWindow>=mrmInfo{firstRow,mrmColIndx(6)} & timeWindow<=mrmInfo{firstRow,mrmColIndx(7)};
    hitSig_out = hitSig_out';
    bgPoints = false(size(hitSig_out));
    bgPoints(find(hitSig_out,1,'last')+1) = true;%right bound
    bgPoints(find(hitSig_out,1,'first')-1) = true;%left bound
    bgStopper = 0;
end
%%%%%%%%%%%%

[~,RTpeak] = max(TIC(hitSig_out));
twSig = timeWindow(hitSig_out);
RTpeak = twSig(RTpeak);

hold on
plot(timeWindow(hitSig_out),zeros(1,sum(hitSig_out)),'xr','MarkerSize',10);
plot([RTchoose RTchoose],axHist.h_handle.YLim,'k--','LineWidth',2);
hold off

subplot(4,4,13:16)
plot(timeWindow,TIC);
hold on
bar(timeWindow(hitSig_out)',TIC(hitSig_out),'FaceColor','none');
if any(bgPoints)
    plot(timeWindow(bgPoints),TIC(bgPoints),'o');
end
hold off
xlim(axHist.h_handle.XLim);
drawnow
if ~extractTrue
    return
end

saveas(gcf,strcat(['fig_' num2str(ii) '_' mrmName '.png']));

%%%%integrate MRMs
wLength = numel(timeWindow);
dataOut = [];
dataOut_snr = [];
%     figure(2)
for i = 1:size(ticMat,1)
%     try
    [dataOut(:,i),dataOut_stdev(:,i)] = integratePeak_V2(mrmMat{i},timeMat{i},timeShift(i),hitSig_out,bgStopper,timeWindow,timeRepVect);    
%     catch
%     end
end

fileN = strcat(['dataOut_' num2str(ii) '_' mrmName '.mat']);
save(fileN,'ii','mrmName','dataOut','timeShift','dataAligned',...
    'timeWindow','hitSig_out','RTpeak', 'dataOut_stdev','fileList');


%{
%%%%%interface notes%%%%%%

runner_qtrap_int2(x)
x can be metabolite name (string) or sequence index (integer)

for hotkeys to work, figure must be "in focus" by first clicking anywhere in the figure, i.e., title bar is highlighted.


z (hold, then release) -> zoom upon release

z (double tap) -> undo zoom

v (hold) -> view info and time of a given track (mouse over)

s (hold) -> select

d (hold) -> deselect

s,d (double tap) -> undo last selection/deselection

comma (tap) -> shift selected track to the left

period (tap) -> shift selected track to the right


e (hold, then release) -> popup raw chromatograms of selected tracks

SHIFT + e -> create new figure of raw chromatograms of selected tracks

w (hold, then release) -> popup shifted/adjusted chromatograms of selected tracks

SHIFT + w -> create new figure of shifted/adjusted chromatograms of selected tracks, with the ability to shift

SHIFT + a -> align selected tracks using SVD

'Save' button -> save shifted track and reload figure

'Reset' button -> reload figure without saving

to do:
read mzML files from the right folder and set up matlab readable data source
interface with excel
specify how to order/group data files before reviewing
final data extraction


%%%%%%%%%%
%}
