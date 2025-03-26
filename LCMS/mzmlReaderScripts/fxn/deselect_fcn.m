function deselect_fcn(figDat,evt,axHist)
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
    newDatDeselected = sum(axHist.timeShift & hitDat');
    if newDatDeselected>0
        disp([num2str(newDatDeselected) ' new datapoints deselected']);
        axHist.timeShift(hitDat) = false;
        if any(axHist.timeShift)
            axHist.p_handle2.XData = axHist.xyData(axHist.timeShift,1);
            axHist.p_handle2.YData = axHist.xyData(axHist.timeShift,2);
        else
            axHist.p_handle2.XData = 0;
            axHist.p_handle2.YData = 0;
            axHist.p_handle2.Visible = 'off';
        end
    end
    return
end

hitDat = axHist.xyData.yBars(:,1)>ySelected(1) & axHist.xyData.yBars(:,2)<ySelected(2);
hitDat(axHist.xyData.yBars(:,1)<ySelected(1) & axHist.xyData.yBars(:,2)>ySelected(2)) = true;

deselectedData = axHist.dataSelectedHistory(:,end) & hitDat;

if any(deselectedData)
    axHist.dataSelectedHistory(:,end+1) = axHist.dataSelectedHistory(:,end);
    axHist.dataSelectedHistory(deselectedData,end) = false;    
    if ~any(axHist.dataSelectedHistory(:,end))
        axHist.p_handle.FaceVertexAlphaData(:) = 64;
    else
        for i = find(deselectedData')
            axHist.p_handle.FaceVertexAlphaData(axHist.xyData.faceAssigned==i) = 40;
        end
    end
end

disp([num2str(sum(deselectedData)) ' datapoints deselected']);

