function shiftDataMouse(figDat,evt,axHist)
plotWindow = 2;
% disp('a')
% disp('b')
kk = str2num(figDat.YLabel.String);%the seq index of track being modified

%%%modify main patch
hitFaces = false(1,axHist.xyData.noFace);
hitFaces(axHist.xyData.faceAssigned==kk) = true;
hitVertices = false(axHist.xyData.noFace*4,1);
for i = find(hitFaces)
    hitVertices(axHist.p_handle.Faces(i,:)) = true;
end
%%%%%%%%%%%%%

if figDat.CurrentPoint(1) > axHist.RTchoose
    axHist.shiftTrack(kk) = axHist.shiftTrack(kk) - 1;
    z1 = axHist.p_handle.Vertices(hitVertices);
    diffEnd = z1(end-1)-z1(end-2);
    zEnd = z1(end);
    z1(1:4) = [];
    z1 = [z1; zEnd; zEnd; zEnd+diffEnd; zEnd+diffEnd];
    axHist.p_handle.Vertices(hitVertices,1) = z1;
%     axHist.p_handle.Vertices(hitVertices) = axHist.p_handle.Vertices(hitVertices) + min(diff(axHist.xyData.timeWindow));

else
    axHist.shiftTrack(kk) = axHist.shiftTrack(kk) + 1;
    z1 = axHist.p_handle.Vertices(hitVertices);
    diffStart = z1(3)-z1(2);
    zStart = z1(1);
    z1(end-3:end) = [];
    z1 = [zStart-diffStart; zStart-diffStart; zStart; zStart; z1];
    axHist.p_handle.Vertices(hitVertices,1) = z1;
%     axHist.p_handle.Vertices(hitVertices) = axHist.p_handle.Vertices(hitVertices) - min(diff(axHist.xyData.timeWindow));
end

noMRMs = size(axHist.mrmMat{kk,1},1);    
timeVect = axHist.timeMat{kk};
hitVect = timeVect>(axHist.RTchoose-plotWindow) & timeVect<(axHist.RTchoose+plotWindow);
hitVectNumeric = find(hitVect);
indexLeft = find(hitVect,1,'first') + axHist.timeShift(kk) + axHist.shiftTrack(kk);
leftTrimmed = 1 - indexLeft;
if leftTrimmed > 0
    hitVectNumeric(1:leftTrimmed) = [];
    indexLeft = 1;
end
indexRight = find(hitVect,1,'last') + axHist.timeShift(kk) + axHist.shiftTrack(kk);
rightTrimmed = indexRight - numel(timeVect);
if rightTrimmed > 0
    hitVectNumeric(end-rightTrimmed+1:end) = [];
    indexRight = numel(timeVect);
end
%%%
existingYLim = ylim;

plot(figDat,timeVect(hitVectNumeric)'*ones(1,noMRMs),axHist.mrmMat{kk,1}(:,indexLeft:indexRight)','-');
hold on
plot([axHist.RTchoose axHist.RTchoose],existingYLim,'-k');
hold off
plotTitle = axHist.fileList{kk};
title(plotTitle,'FontSize',6,'FontWeight','normal');
xlim([axHist.RTchoose-plotWindow axHist.RTchoose+plotWindow]);
ylim(existingYLim);
ylabel(num2str(kk));
if find(axHist.dataSelectedHistory(:,end),1,'last') == kk
    legend(axHist.mrmNameInfo);
end
set(figDat,'ButtonDownFcn',@(src,evt)shiftDataMouse(src,evt,axHist));



%if trueRight is 'true', then will shift selected data to the right
%if "false', then shift selected data to the left
% hitTracks = axHist.dataSelectedHistory(:,end);
% if ~any(hitTracks)
%     return
% end
% hitFaces = false(1,axHist.xyData.noFace);
% for i = find(hitTracks')
%     hitFaces(axHist.xyData.faceAssigned==i) = true;
% end
% hitVertices = false(axHist.xyData.noFace*4,1);
% 
% for i = find(hitFaces)
%     hitVertices(axHist.p_handle.Faces(i,:)) = true;
% end
% 
% 
% if trueRight
%     axHist.p_handle.Vertices(hitVertices) = axHist.p_handle.Vertices(hitVertices) + min(diff(axHist.xyData.timeWindow));
%     axHist.shiftTrack(hitTracks) = axHist.shiftTrack(hitTracks) - 1;
% else
%     axHist.p_handle.Vertices(hitVertices) = axHist.p_handle.Vertices(hitVertices) - min(diff(axHist.xyData.timeWindow));
%     axHist.shiftTrack(hitTracks) = axHist.shiftTrack(hitTracks) + 1;
% end
% 
