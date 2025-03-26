function [timeShift, dataAligned, timeWindow] = alignPeaks_TS(timeMat,dataMat,startTime,stopTime,...
    timeShiftTable, mrmName, rowPickTable,skipAlignment)

%%%pick start and stop time to be the min and max of timeMat
maxShiftSteps = 5;
if startTime<timeMat(1)
    startTime = timeMat(1);
end
if stopTime > timeMat(end)
    stopTime = timeMat(end);
end

%%add 20 flanking zeros%%
dataMat = [zeros(size(dataMat,1),20) dataMat zeros(size(dataMat,1),20)];
if rem(numel(timeMat),2) == 0 %%%is even, then diff is odd
    deltaT = median(diff(timeMat));
else
    deltaT = median([0 diff(timeMat)]);
end

timeMat = [timeMat(1)-20*deltaT:deltaT:timeMat(1)-deltaT...
    timeMat timeMat(end)+deltaT:deltaT:timeMat(end)+20*deltaT];

dataMat = dataMat';
noDat = size(dataMat,2);

startIndex_ori = find(timeMat>startTime,1,'first');
timeWindow = timeMat >=startTime & timeMat<=stopTime;
wLength = sum(timeWindow);
timeWindow = timeMat(timeWindow);
lengthDataMat = size(dataMat,1);

%%%match for mrmName%%%
hitRow = strcmp(mrmName,timeShiftTable(:,1));
if isempty(timeShiftTable) || ~any(hitRow)
    timeShiftIn = zeros(1,noDat);
elseif isempty(timeShiftTable{hitRow,3})
    timeShiftIn = zeros(1,noDat);
else
    timeShiftIn = zeros(1,noDat);
    
    cc = 1;
    for i = 1:numel(rowPickTable)
        for j = 1:numel(rowPickTable{i})
            hitTS = timeShiftTable{hitRow,3} == rowPickTable{i}(j);
            if any(hitTS)
                timeShiftIn(cc) = timeShiftTable{hitRow,2}(hitTS);
            end
            cc = cc + 1;
        end
    end
end

startIndex = timeShiftIn + startIndex_ori;
activeMat = false(size(dataMat));
try
for i = 1:noDat
    activeMat(startIndex(i):startIndex(i)+wLength-1,i) = true;
end
catch
end
abc = zeros(wLength,noDat);
abc(:) = dataMat(activeMat);

if skipAlignment
    timeShift = startIndex - startIndex_ori;
    dataAligned = abc';
    return
end

itt = 1;
while itt <=1000
    
    sOri = svd(abc);
    sOri = sOri(1);
    %     fprintf('%1.0f\t%1.0f\n',itt, sOri);
    svdTest = zeros(noDat,2);
    for i = 1:noDat
        activeMatTemp = activeMat;
        %shift early
        if startIndex(i)-1 == 0
            svdTest(i,1) = 0;
        elseif abs(startIndex(i) - startIndex_ori)> maxShiftSteps
            svdTest(i,1) = 0;
        else
            
            activeMatTemp(:,i) = false;
            activeMatTemp(startIndex(i)-1:startIndex(i)+wLength-2,i) = true;
            abc(:) = dataMat(activeMatTemp);
            s = svd(abc);
            svdTest(i,1) = s(1)-sOri;
        end
        
        %shift late
        if startIndex(i)+wLength > lengthDataMat
            svdTest(i,2) = 0;
        elseif abs(startIndex(i) - startIndex_ori)> maxShiftSteps
            svdTest(i,1) = 0;
        else
            activeMatTemp(:,i) = false;
            activeMatTemp(startIndex(i)+1:startIndex(i)+wLength,i) = true;
            abc(:) = dataMat(activeMatTemp);
            s = svd(abc);
            svdTest(i,2) = s(1)-sOri;
        end
    end
    maxS = max(max(svdTest));
    if maxS<1e-4
        break
    end
    [r,c]=find(svdTest==maxS);
    if c == 1
        startIndex(r) = startIndex(r) - 1;
    else
        startIndex(r) = startIndex(r) + 1;
    end
    activeMat(:,r) = false;
    activeMat(startIndex(r):startIndex(r)+wLength-1,r) = true;
    abc(:) = dataMat(activeMat);
    itt = itt + 1;
end


timeShift = startIndex - startIndex_ori;
timeShift = timeShift - round(median(timeShift));

startIndex = timeShift + startIndex_ori;
activeMat = false(size(dataMat));
for i = 1:noDat
    activeMat(startIndex(i):startIndex(i)+wLength-1,i) = true;
end
abc = zeros(wLength,noDat);
abc(:) = dataMat(activeMat);
dataAligned = abc';
