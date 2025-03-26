function [peakArea_out, stddev_out] = integratePeak_TS(mrmMat,timeMat,timeShift,hitSig,bgPoints, timeWindow)
drawPlot = false;
% drawPlot = true;
% if drawPlot
%     figure(2);
% end
%%%pad mrmMat, then shift integration window
if rem(numel(timeMat),2) == 0 %%%is even, then diff is odd
    timeDiff = median(diff(timeMat));
else
    timeDiff = median([0 diff(timeMat)]);
end

if rem(numel(timeWindow),2) == 0 %%%is even, then diff is odd
    twDiff = median(diff(timeWindow));
else
    twDiff = median([0 diff(timeWindow)]);
end

while any((find(hitSig) + timeShift)<1)
    hitSig = [false; hitSig];
    timeWindow = [timeWindow(1)-twDiff timeWindow];
    if ~isempty(bgPoints) &&  islogical(bgPoints)
        bgPoints = [false;bgPoints];
    end
end

while any((find(hitSig) + timeShift)>numel(timeWindow))
    hitSig = [hitSig; false];
    timeWindow = [timeWindow timeWindow(end)+twDiff];
    if ~isempty(bgPoints) && islogical(bgPoints)
        bgPoints = [bgPoints;false];
    end
end

hitSig_shift = false(size(hitSig));
hitSig_shift(find(hitSig) + timeShift) = true;
intWindow = timeWindow(hitSig_shift);

zeroVect = zeros(size(mrmMat,1),1);

while timeMat(1)>=intWindow(1)
    timeMat = [timeMat(1)-timeDiff timeMat];
    mrmMat = [zeroVect mrmMat];

end
while timeMat(end)<=intWindow(end)
    timeMat = [timeMat timeMat(end)+timeDiff];
    mrmMat = [mrmMat zeroVect];
end
if ~isempty(bgPoints) && islogical(bgPoints)
    while any((find(bgPoints) + timeShift) < 1)
        bgPoints = [false;bgPoints];
        timeWindow = [timeWindow(1)-twDiff timeWindow];
    end
    while any((find(bgPoints) + timeShift) > numel(timeWindow))
        bgPoints = [bgPoints;false];
        timeWindow = [timeWindow timeWindow(end)+twDiff];
    end
        
    bgPoints_shift = false(size(bgPoints));
    bgPoints_shift(find(bgPoints) + timeShift) = true;
    bgWindow = timeWindow(bgPoints_shift);
    while timeMat(1)>=bgWindow(1)
        timeMat = [timeMat(1)-timeDiff timeMat];
        mrmMat = [zeroVect mrmMat];
    end
    while timeMat(end)<=bgWindow(end)
        timeMat = [timeMat timeMat(end)+timeDiff];
        mrmMat = [mrmMat zeroVect];
    end
    
    %%%find best match bg points positions
    bgPoints = false(size(timeMat));
    for i = 1:numel(bgWindow)
        [~,index] = min(abs(timeMat-bgWindow(i)));
        bgPoints(index) = true;
    end
end

%%%find hit signal window

hitWindow = timeMat>=timeWindow(1) & timeMat<=timeWindow(end);
hitSig = timeMat(hitWindow)>=intWindow(1) & timeMat(hitWindow)<=intWindow(end);

peakArea_out = zeros(size(mrmMat,1),1);
stddev_out = peakArea_out;


% function [peakArea snr] = integratePeak_TS(TIC,hitSig,bgPoints, timeWindow)
options = optimset('Display','off');
bgPoints_ori = bgPoints;
for j = 1:size(mrmMat,1)
    TIC = mrmMat(j,hitWindow)';
    thisTimeWindow = timeMat(hitWindow);
%     if all(bgPoints<0)
%         peakArea = sum(TIC(hitSig));
%         snr = -1;
%     elseif isempty(bgPoints)
    if isempty(bgPoints)    
        noTIC = numel(TIC);
        mTIC = max(TIC);
        TICn = TIC/max(TIC);        
        
        yCount = [0:noTIC-1];
        C_left = [ones(noTIC,1) yCount' -yCount'];
        noPeakPoint = sum(hitSig);
        peakPos = find(hitSig);
        C_right = zeros(noTIC,noPeakPoint);
        for i = 1:noPeakPoint
            C_right(peakPos(i),i) = 1;
        end
        C = [C_left C_right];
        
        [x,resnorm,res] = lsqnonneg(C,TICn,options);
        fval = res'*res;
        
        bgLine = C_left*x(1:3)*mTIC;
        bgDiff = TIC(~hitSig) - bgLine(~hitSig);
        MSE_bg = sqrt((bgDiff'*bgDiff)/(numel(bgDiff)-1));
%         bgArea = sum(bgLine(hitSig));
%         peakArea = sum(TIC(hitSig))-bgArea;
        peakArea = sum(x(4:end))*mTIC;        
        
        stddev = MSE_bg*numel(hitSig);
        if drawPlot
            plot(thisTimeWindow,TIC,'k-');
            hold on
            plot(thisTimeWindow(hitSig),TIC(hitSig),'x');
            plot(thisTimeWindow,bgLine,'r--');
            hold off
        end           
    else
        bgPoints = bgPoints_ori(hitWindow);
        %%%for flanking pair of bg points, take slope
        if diff(find(bgPoints))>1
            bgT = find(bgPoints);
            hitSig_trunc = hitSig(bgT(1):bgT(end));
            bgT = timeMat(bgT(1):bgT(end));
            bgLine = drawSlopeBG(timeMat(bgPoints)',TIC(bgPoints),bgT');
            
            peakArea = sum(TIC(hitSig)) - sum(bgLine(hitSig_trunc));
            stddev = std(TIC(bgPoints))*numel(hitSig);
            
        %%%for one sided bg points, take flat line
        else
            bgLine = mean(TIC(bgPoints));
            bgArea = bgLine*sum(hitSig);
            peakArea = sum(TIC(hitSig))-bgArea;
            stddev = std(TIC(bgPoints))*numel(hitSig);
            
        end
        if drawPlot
            plot(thisTimeWindow,TIC,'k-');
            hold on
            plot(thisTimeWindow(hitSig),TIC(hitSig),'x');
            plot(thisTimeWindow(hitSig|bgPoints),bgLine*ones(sum(hitSig)+sum(bgPoints)),'r--');
            plot(thisTimeWindow(bgPoints),TIC(bgPoints),'ro');
            
            hold off
        end
    end
    
    peakArea_out(j) = peakArea;
    stddev_out(j) = stddev;
end
