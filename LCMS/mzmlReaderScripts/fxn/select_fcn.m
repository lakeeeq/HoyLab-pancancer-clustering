function select_fcn(figDat,evt,axHist)
xConvert = axHist.h_handle.Position(3)/diff(axHist.h_handle.XLim);
yConvert = axHist.h_handle.Position(4)/diff(axHist.h_handle.YLim);
% figDat.CurrentPoint
xStart = axHist.h_handle.Position(1) + (figDat.CurrentPoint(1)-axHist.h_handle.XLim(1))*xConvert;%refers to xy axis units
yStart = axHist.h_handle.Position(2) + (figDat.CurrentPoint(3)-axHist.h_handle.YLim(1))*yConvert;
rect_pos = rbbox([xStart yStart  0 0]);

xSelected = [0 rect_pos(3)/xConvert] + (rect_pos(1)-axHist.h_handle.Position(1))/xConvert+axHist.h_handle.XLim(1);
ySelected = [0 rect_pos(4)/yConvert] + (rect_pos(2)-axHist.h_handle.Position(2))/yConvert+axHist.h_handle.YLim(1);

%%%for WLS graph
if isempty(axHist.RTchoose)
    hitDat = axHist.xyData(:,1)>=xSelected(1) & axHist.xyData(:,1)<=xSelected(2) &...
        axHist.xyData(:,2)>=ySelected(1) & axHist.xyData(:,2)<=ySelected(2);
    hitDat(axHist.rowPickTable<0) = false;
    newDatSelected = sum(~axHist.timeShift & hitDat');
    if newDatSelected>0
        disp([num2str(newDatSelected) ' new datapoints selected']);
        axHist.timeShift(hitDat) = true;
        axHist.p_handle2.Visible = 'on';
        axHist.p_handle2.XData = axHist.xyData(axHist.timeShift,1);
        axHist.p_handle2.YData = axHist.xyData(axHist.timeShift,2);
    end    
    return
end

hitDat = axHist.xyData.yBars(:,1)>ySelected(1) & axHist.xyData.yBars(:,2)<ySelected(2);
hitDat(axHist.xyData.yBars(:,1)<ySelected(1) & axHist.xyData.yBars(:,2)>ySelected(2)) = true;

newHitDat = ~axHist.dataSelectedHistory(:,end) & hitDat;

if any(newHitDat)
    if ~any(axHist.dataSelectedHistory(:,end))
        axHist.p_handle.FaceVertexAlphaData(:) = 40;
    end    
    
    for i = find(newHitDat')
        axHist.p_handle.FaceVertexAlphaData(axHist.xyData.faceAssigned==i) = 64;
    end
    axHist.dataSelectedHistory(:,end+1) = axHist.dataSelectedHistory(:,end) | hitDat;
    disp([num2str(sum(newHitDat)) ' new datapoints selected']);
end
