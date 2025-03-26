function examineFig_fcn(axHist,isPopup)
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
            case 'e'
                close(axHist.f2_handle);
                figure(axHist.f_handle);
                set(axHist.f_handle,'KeyPressFcn',@(src,evt)myhotkey1p(src,evt,axHist));
        end
    end


    function plotSelectedChroma(ffIn,axHist)
        figure(ffIn);
        selectTracks = find(axHist.dataSelectedHistory(:,end));
        noTracks = numel(selectTracks);
        rt = axHist.RTchoose;
        subplotHandle = zeros(noTracks,1);
        for i = 1:noTracks
            kk = selectTracks(i);
            plotTitle = axHist.fileList{kk};
            subplotHandle(i) = subplot(noTracks,1,noTracks+1-i);
            axPos = get(subplotHandle(i),'Position');
            axPos([1 3]) = [0.05 0.9];
            set(subplotHandle(i),'Position',axPos);
            noMRMs = size(axHist.mrmMat{kk,1},1);
            plot(axHist.timeMat{kk}'*ones(1,noMRMs),axHist.mrmMat{kk,1}','-');
            hold on
            plot([rt rt],[ylim],'-k');
            hold off
            if i == noTracks
                legend(axHist.mrmNameInfo);
            end
            title(plotTitle,'FontSize',6,'FontWeight','normal');
            xlim([rt-5 rt+5]);
            ylabel(num2str(kk));
        end 
    end

end