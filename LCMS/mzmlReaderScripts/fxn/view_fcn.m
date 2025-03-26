function view_fcn(figDat,evt,axHist)
% disp('v');
if figDat.CurrentPoint(1) > axHist.h_handle.Position(1) + axHist.h_handle.Position(3)
    return
end
if figDat.CurrentPoint(2) > axHist.h_handle.Position(2) + axHist.h_handle.Position(4)
    return
end
xConvert = axHist.h_handle.Position(3)/diff(axHist.h_handle.XLim);
yConvert = axHist.h_handle.Position(4)/diff(axHist.h_handle.YLim);

xCoord = (figDat.CurrentPoint(1) - axHist.h_handle.Position(1))/xConvert + axHist.h_handle.XLim(1);
yCoord = (figDat.CurrentPoint(2) - axHist.h_handle.Position(2))/yConvert + axHist.h_handle.YLim(1);
% disp([xCoord yCoord]);
% dx = xCoord - axHist.xyData(:,1);

%%%for WLS graph
if isempty(axHist.RTchoose)
    xRange = axHist.zoomHistory(end,2)-axHist.zoomHistory(end,1);
    yRange = axHist.zoomHistory(end,4)-axHist.zoomHistory(end,3);
    xDiff = (xCoord - axHist.xyData(:,1))/xRange;
    yDiff = (yCoord - axHist.xyData(:,2))/yRange;
    cartDist = xDiff.^2 + yDiff.^2;
    [minDist,index] = min(cartDist);
    if minDist<1e-4
        dataHit = axHist.xyData(index,:);
        xDataPos = (dataHit(1)-axHist.h_handle.XLim(1))*xConvert+axHist.h_handle.Position(1);
        yDataPos = (dataHit(2)-axHist.h_handle.YLim(1))*yConvert+axHist.h_handle.Position(2);
        if isempty(axHist.hitTrack)
            axHist.dataViewHistory = annotation('textarrow',[xDataPos+0.02 xDataPos],[yDataPos+0.02 yDataPos],'String',axHist.fileList{index});
            axHist.hitTrack = index;
        elseif axHist.hitTrack~=index
            delete(axHist.dataViewHistory);
            axHist.dataViewHistory = annotation('textarrow',[xDataPos+0.02 xDataPos],[yDataPos+0.02 yDataPos],'String',axHist.fileList{index});
            axHist.hitTrack = index;
        end
    else
        delete(axHist.dataViewHistory);
        axHist.hitTrack = [];
    end
    return
end

%for peak calling
hitTrack = find(axHist.xyData.yBars(:,1)<yCoord & axHist.xyData.yBars(:,2)>yCoord);

dy = min(min(abs(axHist.xyData.yBars-yCoord)));
if ~any(yCoord>axHist.xyData.yBars(:,1) & yCoord<axHist.xyData.yBars(:,2))
    delete(axHist.dataViewHistory);
    axHist.hitTrack = [];
    return
end

% disp(hitTrack)
if isempty(axHist.dataViewHistory) || ~isvalid(axHist.dataViewHistory) || strcmp(evt.EventName,'KeyPressFcn')
%     disp(figDat.CurrentPoint)
    axHist.dataViewHistory = annotation('textbox',[figDat.CurrentPoint+[0.04 0.04] 0 0],'String',[num2str(xCoord) ', ' num2str(hitTrack) ', ' num2str(axHist.timeShift(hitTrack)) ', ' axHist.fileList{hitTrack}],'FitBoxToText','on');
    axHist.hitTrack = hitTrack;
elseif axHist.hitTrack == hitTrack
    axHist.dataViewHistory.String = [num2str(xCoord) ', ' num2str(hitTrack) ', ' num2str(axHist.timeShift(hitTrack)) ', ' axHist.fileList{hitTrack}];
elseif axHist.hitTrack ~= hitTrack
    delete(axHist.dataViewHistory);
    axHist.dataViewHistory = annotation('textbox',[figDat.CurrentPoint+[0.04 0.04] 0 0],'String',[num2str(xCoord) ', ' num2str(hitTrack) ', ' num2str(axHist.timeShift(hitTrack)) ', ' axHist.fileList{hitTrack}],'FitBoxToText','on');
    axHist.hitTrack = hitTrack;
end


