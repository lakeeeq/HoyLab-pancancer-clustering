function reloadFig(hObject, eventdata,axHist)
% axHist
set(axHist.f_handle,'KeyPressFcn','','KeyReleaseFcn','','WindowButtonMotionFcn','');
delete(axHist.p_handle);
delete(axHist.h_handle);
delete(axHist.box_handle);
if strcmp(hObject.String,'Save')
    timeShift = axHist.timeShift + axHist.shiftTrack';
    timeShiftTable = saveTimeShiftRT(axHist.timeShiftTable,axHist.mrmName,timeShift,axHist.rowPickTable,axHist.tsFileName,axHist.RTwindow);
    eval(strcat([axHist.scriptName '(' num2str(axHist.metIndex) ')']));
elseif strcmp(hObject.String,'Reload')
    eval(strcat([axHist.scriptName '(' num2str(axHist.metIndex) ')']));
elseif strcmp(hObject.String,'Previous')
    toDo = axHist.metIndex - 1;
    if toDo<1
        toDo = 1;
    end
    eval(strcat([axHist.scriptName '(' num2str(toDo) ')']));
elseif strcmp(hObject.String,'Next')
    toDo = axHist.metIndex + 1;
    eval(strcat([axHist.scriptName '(' num2str(toDo) ')']));
elseif strcmp(hObject.String,'Realign')
    timeShift = axHist.timeShift;
    timeShift(:) = 0;
    RTwindow = [1 1];
    timeShiftTable = saveTimeShiftRT(axHist.timeShiftTable,axHist.mrmName,timeShift,axHist.rowPickTable,axHist.tsFileName,RTwindow);
    eval(strcat([axHist.scriptName '(' num2str(axHist.metIndex) ')']));
elseif strcmp(hObject.String,'Sav & Int')
    timeShift = axHist.timeShift + axHist.shiftTrack';
    timeShiftTable = saveTimeShiftRT(axHist.timeShiftTable,axHist.mrmName,timeShift,axHist.rowPickTable,axHist.tsFileName,axHist.RTwindow);
    eval(strcat([axHist.scriptName '(' num2str(axHist.metIndex) ', true)']));
end


