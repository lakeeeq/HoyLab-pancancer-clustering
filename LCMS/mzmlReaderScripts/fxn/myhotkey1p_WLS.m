function myhotkey1p_WLS(src,evt,axHist)

delete(axHist.box_handle);
switch evt.Key
    case 'z'
        axHist.zoomNext = [];
        set(src,'KeyPressFcn','');
        set(axHist.h_handle,'ButtonDownFcn',@(src,evt)zoom_fcn(src,evt,axHist));
        
    case 's'
        set(src,'KeyPressFcn','');
        set(axHist.h_handle,'ButtonDownFcn',@(src,evt)select_fcn(src,evt,axHist));
        
    case 'd'
        set(src,'KeyPressFcn','');
        set(axHist.h_handle,'ButtonDownFcn',@(src,evt)deselect_fcn(src,evt,axHist));
        
    case 'v'
        set(src,'KeyPressFcn','');
        set(axHist.f_handle,'WindowButtonMotionFcn',@(src,evt)view_fcn(src,evt,axHist));
        
    
end
