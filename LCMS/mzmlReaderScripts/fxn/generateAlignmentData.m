function dataMatIn = generateAlignmentData(axHist)

xBounds = axHist.zoomHistory(end,[1 2]);
noTimePoints = numel(axHist.xyData.timeWindow);
rtSelected = axHist.xyData.timeWindow > xBounds(1) & axHist.xyData.timeWindow < xBounds(2);
wLength = sum(rtSelected);
startOri = find(rtSelected,1,'first');

tracksSelected = find(axHist.dataSelectedHistory(:,end));
dataMatIn = zeros(numel(tracksSelected),wLength);


for i = 1:numel(tracksSelected)
    hitSelectedTrack = tracksSelected(i);
    startActual = startOri + axHist.shiftTrack(hitSelectedTrack);
    if startActual < 1
        wLengthAdjusted = wLength - 1 - abs(startActual);
        dataMatIn(i,end-wLengthAdjusted+1:end) = axHist.xyData.dataAligned(hitSelectedTrack,1:wLengthAdjusted);
    elseif (startActual + wLength -1) > noTimePoints
        wLengthAdjusted = wLength - ((startActual + wLength) - noTimePoints - 1);
        dataMatIn(i,1:wLengthAdjusted) = axHist.xyData.dataAligned(hitSelectedTrack,startActual:startActual+wLengthAdjusted-1);
    else        
        dataMatIn(i,:) = axHist.xyData.dataAligned(hitSelectedTrack,startActual:startActual+wLength-1);
    end
end

