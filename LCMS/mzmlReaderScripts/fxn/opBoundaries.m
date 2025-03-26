function [hitSig_out, bgLine] = opBoundaries(TIC,RTchoose,bgCutOff)

startIndex = RTchoose;
while 1
    testIndexes = [-2 -1 0 1 2] + startIndex;
    Y = TIC(testIndexes);
    X = [ones(1,5); testIndexes];
    b1 = X'\Y;
    if b1(2) < 0
        nextIndexes = testIndexes - 1;
    else
        nextIndexes = testIndexes + 1;
    end
    if any(nextIndexes<4)
        break
    end
    if any(nextIndexes>(numel(TIC)-4))
        break
    end
    
    Y = TIC(nextIndexes);
    X = [ones(1,5); nextIndexes];
    b2 = X'\Y;
    
    if b2(2) >= 0 && b1(2) <= 0
        break
    else
       startIndex = nextIndexes(3);
    end
        
    
end

noTIC = numel(TIC);
mTIC = max(TIC);
TIC = TIC/max(TIC);

options = optimset('Display','off');


yCount = [0:noTIC-1];
C_left = [ones(noTIC,1) yCount' -yCount'];
C_right = zeros(noTIC,1);
C_right(startIndex) = 1;
C = [C_left C_right];

[x,resnorm,res] = lsqnonneg(C,TIC,options);
fval = res'*res;
y = C*x;
% plot(yCount,TIC,'.');
% hold on
% plot(yCount,C_left*x(1:3),'-');
% plot(yCount,C*x,'x');
% plot(yCount(index),y(index),'o');
% hold off
% title(num2str(fval));

hitSigTable = C_right;
fvalTable = fval;
areaInc = x(4);
while 1
    %%%test left%%%
    hitSig_test = hitSigTable(:,end);
    if find(hitSig_test,1,'first')-1 > 4
        hitSig_test(find(hitSig_test,1,'first')-1) = 1;
    end
    noPeakPoint = sum(hitSig_test);
    peakPos = find(hitSig_test);
    C_right = zeros(noTIC,noPeakPoint);
    for i = 1:noPeakPoint
        C_right(peakPos(i),i) = 1;
    end
    C_l = [C_left C_right];
    [x_left,resnorm,res] = lsqnonneg(C_l,TIC,options);
    fval_left = res'*res;
    
    %%%test right
    hitSig_test = hitSigTable(:,end);
    if find(hitSig_test,1,'last')+1 <= numel(hitSig_test)-4
        hitSig_test(find(hitSig_test,1,'last')+1) = 1;
    end
    noPeakPoint = sum(hitSig_test);
    peakPos = find(hitSig_test);
    C_right = zeros(noTIC,noPeakPoint);
    for i = 1:noPeakPoint
        C_right(peakPos(i),i) = 1;
    end
    C_r = [C_left C_right];
    [x_right,resnorm,res] = lsqnonneg(C_r,TIC,options);
    fval_right = res'*res;
    
    
    if fval_left < fval_right
        hitSig_test = hitSigTable(:,end);
        if hitSig_test(1)~=1 && find(hitSig_test,1,'first')-1 > 4
            hitSig_test(find(hitSig_test,1,'first')-1) = 1;
        end
        hitSigTable(:,end+1) = hitSig_test;

        fvalTable(end+1) = fval_left;
        x = x_left;
        C = C_l;
        areaInc(end+1) = sum(x(4:end));
    else
        hitSig_test = hitSigTable(:,end);
        if hitSig_test(end) ~= 1 && find(hitSig_test,1,'last')+1 <= numel(hitSig_test)-4
            hitSig_test(find(hitSig_test,1,'last')+1) = 1;
        end
       
        hitSigTable(:,end+1) = hitSig_test;

        fvalTable(end+1) = fval_right;
        x = x_right;
        C = C_r;
        areaInc(end+1) = sum(x(4:end));
        
    end
    
    hitSig = hitSigTable(:,end)~=0;
    y = C*x;
%     cla
%     plot(yCount,TIC,'.');
%     hold on
%     plot(yCount,C_left*x(1:3),'-');
%     plot(yCount,C*x,'x');
%     plot(yCount(hitSig),y(hitSig),'o');
%     hold off
%     title(num2str(fvalTable(end)));
    
    incFract = (areaInc(end)-areaInc(end-1))/areaInc(end-1);
    if incFract < bgCutOff || isnan(incFract)
        bgLine = C_left*x(1:3)*mTIC;
        break
    end
    if all(hitSigTable(:,end-1)==hitSigTable(:,end))
        break
    end
end
hitSig_out = hitSigTable(:,end)~=0;






