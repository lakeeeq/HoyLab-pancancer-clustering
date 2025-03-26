function [peakArea_out, stddev_out] = integratePeak_V2(mrmMat,timeMat,timeShift,hitSig,bgStopper,timeWindow,timeRepVect)
% drawPlot = false;
drawPlot = true;
if drawPlot
    figure(2);
end
startTW = find(timeRepVect==timeWindow(1)) + timeShift;
if startTW <= 0
    startTW = 1;
end
endTW = find(timeRepVect==timeWindow(end))+timeShift;
if endTW > numel(timeRepVect)
    endTW = numel(timeRepVect);
end
% try
newTW = timeMat>=timeRepVect(startTW) & timeMat<=timeRepVect(endTW);
% catch
% end
timeVect = timeMat(newTW);

startIW = find(timeRepVect==timeWindow(find(hitSig,1,'first'))) + timeShift;
endIW = find(timeRepVect==timeWindow(find(hitSig,1,'last'))) + timeShift;
newHitSig = timeVect>=timeRepVect(startIW) & timeVect<=timeRepVect(endIW);

bgPointBound = false(size(newHitSig));
if ~isempty(bgStopper)
    if bgStopper == -1
        bgPointBound(find(newHitSig,1,'first')-1) = true;
    elseif bgStopper == 1
        bgPointBound(find(newHitSig,1,'last')+1) = true;
    else
        bgPointBound(find(newHitSig,1,'first')-1) = true;
        bgPointBound(find(newHitSig,1,'last')+1) = true;
    end
end


options = optimset('Display','off');


TIC = sum(mrmMat(:,newTW),1)';
noTIC = numel(TIC);
mTIC = max(TIC);
TICn = TIC/max(TIC);

notOKforBG = false(size(newHitSig));
noPeakPoint = sum(newHitSig);
peakPos = find(newHitSig);
yCount = [0:noTIC-1];
C_left = [ones(noTIC,1) yCount' -yCount'];
C_left_ori = C_left;
C_right = zeros(noTIC,noPeakPoint);
for i = 1:noPeakPoint
    C_right(peakPos(i),i) = 1;
end
while 1
    C_left(notOKforBG,:) = 0;
    TICn(notOKforBG) = 0;
    C = [C_left C_right];
    x = lsqnonneg(C,TICn,options);
    bgLine = C_left*x(1:3)*mTIC;
    currentBGpoints = find(~newHitSig & ~notOKforBG);
    bgDiff = TIC(currentBGpoints) - bgLine(currentBGpoints);
    bgSTD = std(bgDiff);
    hitBadBG = bgDiff> 3*bgSTD | bgDiff< -3*bgSTD;
    if any(hitBadBG)
        notOKforBG(currentBGpoints(hitBadBG)) = true;
    else
        break
    end
end
if drawPlot
    bgLine = C_left_ori*x(1:3)*mTIC;
    plot(timeVect,TIC,'k-');
    hold on
    plot(timeVect(newHitSig),TIC(newHitSig),'x');
    plot(timeVect,bgLine,'r--');
    plot(timeVect(notOKforBG),bgLine(notOKforBG),'rx');
    plot(timeVect(notOKforBG),TIC(notOKforBG),'ro');
    hold off
end
%%%%add nonBG LHS/RHS of peak to peak signal (for broad peaks)
xDiff = [1:4]-2.5;

while 1
    checkLeft = find(newHitSig,1,'first')-1;
    if notOKforBG(checkLeft) %&& ~bgPointBound(checkLeft)
        y1 = TIC(checkLeft:1:checkLeft+3);
        yDiff = y1-mean(y1);
        mx = xDiff*yDiff;
        if mx<=0
            break
        end
        if TIC(checkLeft) > TIC(checkLeft+1)+2*bgSTD
            break
        end
        
        newHitSig(checkLeft) = true;
        notOKforBG(checkLeft) = false;
    else
        break
    end
end
while 1
    checkRight = find(newHitSig,1,'last')+1;
    if notOKforBG(checkRight)% && ~bgPointBound(checkRight)
        y1 = TIC(checkRight-3:1:checkRight);
        yDiff = y1-mean(y1);
        mx = xDiff*yDiff;
        if mx>=0
            break
        end
        if TIC(checkRight) > TIC(checkRight-1)+2*bgSTD
            break
        end
        
        newHitSig(checkRight) = true;
        notOKforBG(checkRight) = false;
    else
        break
    end
end

noPeakPoint = sum(newHitSig);
peakPos = find(newHitSig);

for j = 1:size(mrmMat,1)
    TIC = mrmMat(j,newTW)';
    noTIC = numel(TIC);
    mTIC = max(TIC);
    TICn = TIC/max(TIC);
    yCount = [0:noTIC-1];
    C_left = [ones(noTIC,1) yCount' -yCount'];
    C_left_ori = C_left;
    C_right = zeros(noTIC,noPeakPoint);
    for i = 1:noPeakPoint
        C_right(peakPos(i),i) = 1;
    end
    C_left(notOKforBG,:) = 0;
    TICn(notOKforBG) = 0;
    C = [C_left C_right];
    x = lsqnonneg(C,TICn,options);
    
    bgLine = C_left*x(1:3)*mTIC;
    currentBGpoints = find(~newHitSig & ~notOKforBG);
    bgDiff = TIC(currentBGpoints) - bgLine(currentBGpoints);
    
    MSE_bg = sqrt((bgDiff'*bgDiff)/(numel(bgDiff)-1));
    peakArea = sum(x(4:end))*mTIC;
    stddev = MSE_bg*noPeakPoint;
    
    peakArea_out(j) = peakArea;
    stddev_out(j) = stddev;
    
    if drawPlot
        bgLine = C_left_ori*x(1:3)*mTIC;
        plot(timeVect,TIC,'k-');
        hold on
        plot(timeVect(newHitSig),TIC(newHitSig),'x');
        plot(timeVect,bgLine,'r--');
        plot(timeVect(notOKforBG),bgLine(notOKforBG),'rx');
        plot(timeVect(notOKforBG),TIC(notOKforBG),'ro');
        hold off
    end
end
