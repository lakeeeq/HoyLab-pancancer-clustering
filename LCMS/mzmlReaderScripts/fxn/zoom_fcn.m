function zoom_fcn(figDat,evt,axHist)
xConvert = axHist.h_handle.Position(3)/diff(axHist.h_handle.XLim);
yConvert = axHist.h_handle.Position(4)/diff(axHist.h_handle.YLim);
% figDat.CurrentPoint
xStart = axHist.h_handle.Position(1) + (figDat.CurrentPoint(1)-axHist.h_handle.XLim(1))*xConvert;%refers to xy axis units
yStart = axHist.h_handle.Position(2) + (figDat.CurrentPoint(3)-axHist.h_handle.YLim(1))*yConvert;
rect_pos = rbbox([xStart yStart  0 0]);
if rect_pos(3)<0.01 || rect_pos(4)< 0.01 %too narrow zoom
    disp('selection too narrow');
    return
end
if isempty(axHist.box_handle) || ~isvalid(axHist.box_handle)
    axHist.box_handle = annotation(axHist.f_handle,'rectangle',rect_pos,'Color','r','LineStyle',':');
    
else
    axHist.box_handle.Position = rect_pos;
end

zoomNext = [(rect_pos(1)-axHist.h_handle.Position(1))/xConvert+axHist.h_handle.XLim(1) 0 (rect_pos(2)-axHist.h_handle.Position(2))/yConvert+axHist.h_handle.YLim(1) 0];
zoomNext(2) = zoomNext(1) + rect_pos(3)/xConvert;
zoomNext(4) = zoomNext(3) + rect_pos(4)/yConvert;
axHist.zoomNext = zoomNext;

