classdef figCont < handle
    properties
        f_handle %figure
        f2_handle
        p_handle %plot
        p_handle2 %plot
        h_handle %axes
        box_handle %annotation box
        boxHistory
        zoomHistory
        zoomNext
        z_lastReleased = tic;
        xyData
        s_lastReleased = tic;
        d_lastReleased = tic;
        dataSelectedHistory
        dataViewHistory %data visualised in annot box
        hitTrack
        shiftTrack
        scriptName
        metIndex
        
        timeShiftTable
        tsFileName
        timeShift
        rowPickTable
        fileList
        mrmName
        mrmNameInfo  
        mrmInfo
        mrmMat
        timeMat
        RTchoose
        RTwindow
%         timeRepVect
%         intMat
    end
end