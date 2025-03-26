function timeShift = svdAlign(dataMat)
maxShiftSteps = 5;
zeroPadding = 20;

[noData, wLength] = size(dataMat);
startIndex_ori = ones(noData,1)*(zeroPadding+1);
startIndex = startIndex_ori;
dataMatPadded = [zeros(noData,zeroPadding) dataMat zeros(noData,zeroPadding)]';
activeMat = [false(noData,zeroPadding) true(size(dataMat)) false(noData,zeroPadding)]';

abc = zeros(wLength,noData);
abc(:) = dataMatPadded(activeMat);

itt = 1;
disp('aligning... please wait.');
while itt <=1000
    
    sOri = svd(abc);
    sOri = sOri(1);
    svdTest = zeros(noData,2);
    for i = 1:noData
        %shift early
        if startIndex(i)-1 == 0
            svdTest(i,1) = 0;
        elseif abs(startIndex(i) - startIndex_ori)> maxShiftSteps
            svdTest(i,1) = 0;
        else            
            activeMatTemp = false(wLength+2*zeroPadding,1);
            activeMatTemp(startIndex(i)-1:startIndex(i)+wLength-2) = true;
            abc(:,i) = dataMatPadded(activeMatTemp,i);
            s = svd(abc);
            svdTest(i,1) = s(1)-sOri;
            abc(:,i) = dataMatPadded(activeMat(:,i),i);%reset
        end
        
        %shift late
        if startIndex(i) > 2*zeroPadding %(startIndex(i)+wLength) > {wLength+2*zeroPadding)
            svdTest(i,2) = 0;
        elseif abs(startIndex(i) - startIndex_ori)> maxShiftSteps
            svdTest(i,1) = 0;
        else
            activeMatTemp = false(wLength+2*zeroPadding,1);
            activeMatTemp(startIndex(i)+1:startIndex(i)+wLength) = true;
            abc(:,i) = dataMatPadded(activeMatTemp,i);
            s = svd(abc);
            svdTest(i,2) = s(1)-sOri;
            abc(:,i) = dataMatPadded(activeMat(:,i),i);%reset
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
    abc(:) = dataMatPadded(activeMat);
    itt = itt + 1;
end

timeShift = startIndex - startIndex_ori;
timeShift = timeShift - round(median(timeShift));
disp('aligned');