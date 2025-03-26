function examineShiftedFig_fcn(axHist,isPopup)
if isPopup
    axHist.f2_handle = figure;
    plotSelectedChroma(axHist.f2_handle,axHist);
    set(axHist.f2_handle,'KeyReleaseFcn',@autoCloseKey,'WindowStyle','modal','Units','normalized','Position',[0.03 0.04 0.6 0.7]);
else
    ff = figure;
    plotSelectedChroma(ff,axHist);
    set(ff,'WindowStyle','dock');
end

    function autoCloseKey(src,evt)%%%close the popup
        switch evt.Key
            case 'w'
                close(axHist.f2_handle);
                figure(axHist.f_handle);
                set(axHist.f_handle,'KeyPressFcn',@(src,evt)myhotkey1p(src,evt,axHist));
        end
    end


    function plotSelectedChroma(ffIn,axHist)
        plotWindow = 2;
        figure(ffIn);
        selectTracks = find(axHist.dataSelectedHistory(:,end));
        noTracks = numel(selectTracks);
        rt = axHist.RTchoose;
        timeShifted = axHist.timeShift + axHist.shiftTrack';
        
        subplotHandle = zeros(noTracks,1);
        
        for i = 1:noTracks
            kk = selectTracks(i);
            plotTitle = axHist.fileList{kk};
            subplotHandle(i) = subplot(noTracks,1,noTracks+1-i);
            axPos = get(subplotHandle(i),'Position');
            axPos([1 3]) = [0.1 0.8];
            set(subplotHandle(i),'Position',axPos);
            noMRMs = size(axHist.mrmMat{kk,1},1);
            %shift timeMat vector
            timeVect = axHist.timeMat{kk};
            hitVect = timeVect>(rt-plotWindow) & timeVect<(rt+plotWindow);
            indexLeft = find(hitVect,1,'first') + timeShifted(kk);
            if indexLeft<1
                hitVect(1:1-indexLeft) = false;
                indexLeft = 1;                
            end
            indexRight = find(hitVect,1,'last') + timeShifted(kk);
            if indexRight > numel(timeVect)
                hitVect((2*numel(timeVect)-indexRight+1):end) = false;
                indexRight = numel(timeVect);
            end
            
            %%%
            try
            plot(timeVect(hitVect)'*ones(1,noMRMs),axHist.mrmMat{kk,1}(:,indexLeft:indexRight)','-');
            catch
                plot(timeVect(hitVect)'*ones(1,noMRMs),axHist.mrmMat{kk,1}(:,indexLeft:indexLeft+sum(hitVect)-1)','-');
            end
            hold on
            plot([rt rt],[ylim],'-k');
            hold off
            if i == noTracks
                legend(axHist.mrmNameInfo);
            end
            title(plotTitle,'FontSize',6,'FontWeight','normal');
            xlim([rt-plotWindow rt+plotWindow]);
            ylabel(num2str(kk));
            
            set(subplotHandle(i),'ButtonDownFcn',@(src,evt)shiftDataMouse(src,evt,axHist));
        end 
    end

end