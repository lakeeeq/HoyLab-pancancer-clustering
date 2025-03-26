function myhotkey1p(src,evt,axHist)
%for zoooming
% disp('p')
% disp(evt)
if numel(evt.Modifier) == 2
    if strcmp(evt.Modifier{1},'shift') && strcmp(evt.Modifier{2},'control')
        if evt.Key == 'r'
            set(axHist.f_handle,'KeyPressFcn','','KeyReleaseFcn','');
            scriptName = axHist.scriptName;
            metIndex = num2str(axHist.metIndex);
            clearvars axHist
            eval(strcat([scriptName '(' metIndex ')']));
            boxHistory = [];
            return
        elseif evt.Key == 's'
            timeShift = axHist.timeShift + axHist.shiftTrack';
            timeShiftTable = saveTimeShift(axHist.timeShiftTable,axHist.mrmName,timeShift,axHist.rowPickTable,axHist.tsFileName);
            set(src,'KeyPressFcn','');
            run(axHist.scriptName);
            return
        end
        
    end
end

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
        
    case 'comma'
        delete(axHist.box_handle);
        set(src,'KeyPressFcn','');
        
    case 'period'
        set(src,'KeyPressFcn','');
        
    case 'e'
        if any(axHist.dataSelectedHistory(:,end))
            if strcmp(evt.Modifier,'shift')
                examineFig_fcn(axHist,false);
            elseif isempty(evt.Modifier)
                set(src,'KeyPressFcn','');
                examineFig_fcn(axHist,true);
            end
        end
        
    case 'w'
        if any(axHist.dataSelectedHistory(:,end))
            if strcmp(evt.Modifier,'shift')
                examineShiftedFig_fcn(axHist,false);
            else
                set(src,'KeyPressFcn','');
                examineShiftedFig_fcn(axHist,true);
            end
        end
        
    case 'a'
        if any(axHist.dataSelectedHistory(:,end))
            if strcmp(evt.Modifier,'shift')
                dataMatIn = generateAlignmentData(axHist);
                svdTimeShifted = svdAlign(dataMatIn);
                if any(svdTimeShifted~=0)
                    shiftDataSVD(axHist,svdTimeShifted);
                    assignin('base','axHistShow',axHist)
                end
            end
        end
end
