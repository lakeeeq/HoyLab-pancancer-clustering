function axHist = plotDataIntoPatch2(dataAligned,timeWindow,fileGrp)
noData = size(dataAligned,1);
noT = numel(timeWindow);
dataAlignedOriginal = dataAligned;
%%%normalize to max per line
for i = 1:noData
    dataAligned(i,:) = dataAligned(i,:)./max(dataAligned(i,:));
end
%%%%normalize to max of all
% dataAligned = dataAligned/max(max(dataAligned));


dataAligned_color = round(dataAligned*63)+1;
yWidth = 1/noData;
yBase = [0:yWidth:1];
fileGrp(end+1) = fileGrp(end);
fg_unique = unique(fileGrp);
for i = 1:numel(fg_unique)
    yBase(fileGrp==fg_unique(i)) = yBase(fileGrp==fg_unique(i)) + 5*yWidth*(i-1);
end

xdata = [];
ydata = [];
cdata = [];
faceAssigned = [];
for i = 1:noData
    for j = 1:noT-1%%%end-1
        xdata(:,end+1) = [timeWindow(j) timeWindow(j) timeWindow(j+1) timeWindow(j+1)];
        ydata(:,end+1) = [yBase(i) yBase(i)+yWidth yBase(i)+yWidth yBase(i)];
        cdata(:,end+1) = [dataAligned_color(i,j) dataAligned_color(i,j) dataAligned_color(i,j+1) dataAligned_color(i,j+1)];
        faceAssigned(end+1) = i;
    end
end

cla
axHist = figCont;

axHist.p_handle = patch(xdata,ydata,cdata,'EdgeAlpha', 0);
axHist.h_handle = get(axHist.p_handle,'Parent');
axHist.f_handle = get(axHist.h_handle,'Parent');
axHist.h_handle.YTick = yBase;
axHist.h_handle.YTickLabel = [1:noData 0];
% axHist.h_handle.YTickLabel = [axHist.h_handle.YTickLabel; '  '];
axHist.h_handle.XLim = axHist.h_handle.XLim ;
axHist.h_handle.YLim = axHist.h_handle.YLim ;

set(axHist.p_handle,'HitTest','off');

colormap('parula');
axHist.p_handle.FaceVertexAlphaData = 64*ones(size(xdata,2),1);
axHist.p_handle.FaceAlpha = 'flat';
axHist.p_handle.AlphaDataMapping = 'direct';


axHist.zoomHistory = [axHist.h_handle.XLim axHist.h_handle.YLim];

axHist.xyData.timeWindow = timeWindow;
axHist.xyData.dataAligned = dataAlignedOriginal;
axHist.xyData.yBars = [yBase' yBase'+yWidth];
axHist.xyData.yBars(end,:) = [];
axHist.xyData.noData = noData;
axHist.xyData.noFace = size(xdata,2);
axHist.xyData.faceAssigned = faceAssigned;
axHist.shiftTrack = zeros(noData,1);


axHist.dataSelectedHistory = false(noData,1);
set(axHist.f_handle,'Units','normalize');
set(axHist.h_handle,'Units','normalize');
