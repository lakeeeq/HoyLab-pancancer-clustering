function reloadFig_WLS(hObject, eventdata,axHist)
% axHist
set(axHist.f_handle,'KeyPressFcn','','KeyReleaseFcn','','WindowButtonMotionFcn','');
delete(axHist.p_handle);
delete(axHist.h_handle);
delete(axHist.box_handle);
if strcmp(hObject.String,'Save')
    
    stdExclude = axHist.timeShiftTable;
    hitNewSelection = ~stdExclude(axHist.metIndex,:) & axHist.timeShift;
    hitNewDeSelection = stdExclude(axHist.metIndex,:) & axHist.timeShift;
    stdExclude(axHist.metIndex,hitNewSelection) = true;
    stdExclude(axHist.metIndex,hitNewDeSelection) = false;
    save(axHist.tsFileName,'stdExclude');
    disp('saved')
    eval(strcat([axHist.scriptName '(' num2str(axHist.metIndex) ')']));
elseif strcmp(hObject.String,'Reset')
    stdExclude = axHist.timeShiftTable;
    stdExclude(axHist.metIndex,:) = false;
    save(axHist.tsFileName,'stdExclude');
    disp('reloaded')
    eval(strcat([axHist.scriptName '(' num2str(axHist.metIndex) ')']));
elseif strcmp(hObject.String,'Previous')
    if axHist.mrmMat%sum met
        goodRows = find(axHist.mrmNameInfo==1 & ~strcmp(axHist.mrmName,axHist.mrmInfo));
    else
        goodRows = find(axHist.mrmNameInfo==1);        
    end
    hitRows = goodRows<axHist.metIndex;
    if any(hitRows)
        toDo = goodRows(find(hitRows,1,'last'));
    else
        toDo = axHist.metIndex;
    end    
    eval(strcat([axHist.scriptName '(' num2str(toDo) ')']));
elseif strcmp(hObject.String,'Next')
    if axHist.mrmMat%sum met
        goodRows = find(axHist.mrmNameInfo==1 & ~strcmp(axHist.mrmName,axHist.mrmInfo));
    else
        goodRows = find(axHist.mrmNameInfo==1);        
    end
    hitRows = goodRows>axHist.metIndex;
    if any(hitRows)
        toDo = goodRows(find(hitRows,1,'first'));
    else
        toDo = axHist.metIndex;
    end    
    eval(strcat([axHist.scriptName '(' num2str(toDo) ')']));
end


