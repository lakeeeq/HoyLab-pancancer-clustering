function output = fxnWLS(intensityInput,axHist,wlsPower)

%concTags relative concentration, -1 ignore, -2 samples
%intensityInput intensity (peak area)
%datExclude: datapoint exclude
axHist.xyData(:,2) = intensityInput';
concTags = axHist.rowPickTable;
axHist.xyData(concTags>=0,1) = concTags(concTags>=0);
calibExclude = axHist.timeShiftTable(axHist.metIndex,:);
hitSTD = concTags>=0 & ~calibExclude;
Xall = concTags(concTags>=0);
Yall = intensityInput(concTags>=0);
Yexclude = calibExclude(concTags>=0);

n = sum(hitSTD);
Y = intensityInput(hitSTD)';
X = concTags(hitSTD)';
hitZero = X==0;
W = 1./X.^wlsPower;
W(hitZero) = -1;
Wmax = max(W);
W(hitZero) = max(W);
intensitySamples = intensityInput(concTags==-2);
noSamples = numel(intensitySamples);
% out = myLinearFit(X,Y,W,0);

Xmean = W'*X/sum(W);
Ymean = W'*Y/sum(W);
Sxy = W'*((X-Xmean).*Y);
Sxx = W'*(X-Xmean).^2;
Syy = W'*(Y-Ymean).^2;

m = Sxy/Sxx;%slope
c = Ymean - m*Xmean;%intercept
output.slope = m;
output.intercept = c;
Ypred = c + m*X;

Yres = W.*(Y-Ypred);
Stot = W'*(Y-Ypred).^2;
Sres = sqrt(Stot/(n-2));%rmse
Rsquare = 1-Stot/Syy;

Xsim = [0:(max(X)-min(X))/100:max(X)]';
Wsim = 1./Xsim.^2;
Wsim(Xsim<min(X)) = Wmax;
Ysim = c + m*Xsim;
SEpredInt = Sres*sqrt(1./Wsim + 1/sum(W) + (Xsim - Xmean).^2/Sxx);
YpredInt = [Ysim-SEpredInt Ysim+SEpredInt];

clf
axHist.h_handle = subplot(5,1,[1:3]);
plot(Xsim,Ysim);
hold on
axHist.p_handle2 = plot(0,0,'ro','MarkerSize',12);
set(axHist.p_handle2,'Visible','off');
cData = ones(numel(Xall),1)*[0 0 1];
cData(Yexclude,:) = ones(sum(Yexclude),1)*[1 0 0];
axHist.p_handle = scatter(Xall,Yall,100,cData,'.');
plot(Xsim,YpredInt(:,1));
plot(Xsim,YpredInt(:,2));
hold off

f_all = @(x,PM,LHS)seFunct_WLS(x,PM,LHS,min(X),c,m,Sres,sum(W),Xmean,Sxx,Wmax,wlsPower);

Ycrit = c + Sres*sqrt(1/Wmax + 1/sum(W) + Xmean^2/Sxx);%critical Y limit, zero conc is 0
Xcrit = (Ycrit-c)/m;%critical X limit that gives Ycrit

Xdec = fminsearch(@(x) f_all(x,-1,Ycrit),Xcrit);%limit of detection, conc above 0 with confidence non-zero detection

output.calibCurveStats = [Ycrit Xcrit Xdec Rsquare];


concOutput = zeros(noSamples,4);%non symmetrical bounds, take max, 1 std

for i = 1:noSamples
    concOutput(i,1) = (intensitySamples(i)-c)/m;

    concOutput(i,2) = fminsearch(@(x) f_all(x,1,intensitySamples(i)),concOutput(i,1));
    concOutput(i,3) = fminsearch(@(x) f_all(x,-1,intensitySamples(i)),concOutput(i,1));
    concOutput(i,4) = max(concOutput(i,3)-concOutput(i,1),concOutput(i,1)-concOutput(i,2));
%     conc1(i,4) = Sres/m*sqrt(conc1(i,1) + 1/sum(W) + (samples1(i) - Ymean).^2/Sxx/m^2);

   
%     plot(concOutput(i,2),intensitySamples(i),'x');
%     plot(concOutput(i,3),intensitySamples(i),'x');
    
end
hold on
plot(concOutput(:,1),intensitySamples,'kx');
hold off
axHist.xyData(concTags==-2,1) = concOutput(:,1);
output.concOutput = concOutput;

hold on
% plot([Xcrit Xcrit],ylim,'r-');
plot([Xdec Xdec],ylim,'r-');
hold off

subplot(5,1,4);
plot(X,Yres,'x');
hold on
plot(axHist.h_handle.XLim,[0 0],'-');
hold off
xlim(axHist.h_handle.XLim);


hh = subplot(5,1,5);
aa = bar(concOutput(:,1));
aa.FaceColor = 'flat';
aa.CData(concOutput(:,1)<0,:) = ones(sum(concOutput(:,1)<0),1)*[1 0 0];
hh.XTick = 1:noSamples;
hh.XTickLabel=axHist.fileList(concTags==-2);
hh.XTickLabelRotation = 90;
hh.FontSize = 6;
hh.YLim(2) = max(concOutput(:,3));
hold on
plot([1:noSamples; 1:noSamples],concOutput(:,2:3)','r-');
plot([0 noSamples],[Xdec Xdec],'g-')
plot([0 noSamples],[max(X) max(X)],'r:')
hold off

