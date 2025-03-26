function myhotkey1r_WLS(src,evt,axHist)
%for zoooming
assignin('base','axHist',axHist)
switch evt.Key
    case 'z'
        if ~isempty(axHist.z_lastReleased) && toc(axHist.z_lastReleased) < 0.4
            if size(axHist.zoomHistory,1)>1
                axHist.zoomHistory(end,:) = [];
            end
            axHist.h_handle.XLim = axHist.zoomHistory(end,[1 2]);
            axHist.h_handle.YLim = axHist.zoomHistory(end,[3 4]);
            
            if size(axHist.boxHistory,1)> 0
                axHist.box_handle = annotation(axHist.f_handle,'rectangle',axHist.boxHistory(end,:),'Color','r','LineStyle','--');
                axHist.boxHistory(end,:) = [];
            end
            disp('undo zoom');
        end
        
        if ~isempty(axHist.zoomNext)
            axHist.zoomHistory(end+1,:) = axHist.zoomNext; %new XY limits
            axHist.h_handle.XLim = axHist.zoomNext([1 2]);
            axHist.h_handle.YLim = axHist.zoomNext([3 4]);
            axHist.boxHistory(end+1,:) = axHist.box_handle.Position;
            
            disp('zoomed')
            delete(axHist.box_handle);
        end
        axHist.z_lastReleased = tic;
        set(src,'KeyPressFcn',@(src,evt)myhotkey1p(src,evt,axHist));
        set(axHist.h_handle,'ButtonDownFcn','');
        
        
    case 's'
        if ~isempty(axHist.dataSelectedHistory) && toc(axHist.s_lastReleased) < 0.4
            if size(axHist.dataSelectedHistory,2)>1
                axHist.dataSelectedHistory(:,end) = [];
            end
            if isempty(axHist.dataSelectedHistory) || ~any(axHist.dataSelectedHistory(:,end))
                axHist.p_handle.FaceVertexAlphaData(:) = 64;
                disp('empty selection');
            else
                for i = find(axHist.dataSelectedHistory(:,end)')
                    axHist.p_handle.FaceVertexAlphaData(axHist.xyData.faceAssigned==i) = 64;
                end
                for i = find(~axHist.dataSelectedHistory(:,end)')
                    axHist.p_handle.FaceVertexAlphaData(axHist.xyData.faceAssigned==i) = 40;
                end                
                disp('undo previous (de)selection');
            end            
        end
        
        
        axHist.s_lastReleased = tic;
        set(src,'KeyPressFcn',@(src,evt)myhotkey1p(src,evt,axHist));
        set(axHist.h_handle,'ButtonDownFcn','');
        
    case 'd'
        if ~isempty(axHist.dataSelectedHistory) && toc(axHist.d_lastReleased) < 0.4
            if size(axHist.dataSelectedHistory,2)>1
                axHist.dataSelectedHistory(:,end) = [];
            end
            if isempty(axHist.dataSelectedHistory) || ~any(axHist.dataSelectedHistory(:,end))
                axHist.p_handle.FaceVertexAlphaData(:) = 64;
                disp('empty selection');
            else
                for i = find(axHist.dataSelectedHistory(:,end)')
                    axHist.p_handle.FaceVertexAlphaData(axHist.xyData.faceAssigned==i) = 64;
                end
                for i = find(~axHist.dataSelectedHistory(:,end)')
                    axHist.p_handle.FaceVertexAlphaData(axHist.xyData.faceAssigned==i) = 40;
                end
                disp('undo previous (de)selection');
            end
        end
        
        axHist.d_lastReleased = tic;
        set(src,'KeyPressFcn',@(src,evt)myhotkey1p(src,evt,axHist));
        set(axHist.h_handle,'ButtonDownFcn','');
        
    case 'v'
        set(src,'KeyPressFcn',@(src,evt)myhotkey1p(src,evt,axHist));
        set(axHist.f_handle,'WindowButtonMotionFcn','');
        delete(axHist.dataViewHistory);
        axHist.hitTrack = [];        
    
end