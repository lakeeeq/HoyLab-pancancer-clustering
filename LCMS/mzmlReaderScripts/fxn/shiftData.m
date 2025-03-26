function shiftData(trueRight,axHist)
%if trueRight is 'true', then will shift selected data to the right
%if "false', then shift selected data to the left
hitTracks = axHist.dataSelectedHistory(:,end);
if ~any(hitTracks)
    return
end
hitFaces = false(1,axHist.xyData.noFace);
for i = find(hitTracks')
    hitFaces(axHist.xyData.faceAssigned==i) = true;
end
hitVertices = false(axHist.xyData.noFace*4,1);

for i = find(hitFaces)
    hitVertices(axHist.p_handle.Faces(i,:)) = true;
end


if trueRight
    z1 = axHist.p_handle.Vertices(hitVertices);
    diffEnd = z1(end-1)-z1(end-2);
    zEnd = z1(end);
    z1(1:4) = [];
    z1 = [z1; zEnd; zEnd; zEnd+diffEnd; zEnd+diffEnd];
    axHist.p_handle.Vertices(hitVertices,1) = z1;axHist.shiftTrack(hitTracks) = axHist.shiftTrack(hitTracks) - 1;
else
    z1 = axHist.p_handle.Vertices(hitVertices);
    diffStart = z1(3)-z1(2);
    zStart = z1(1);
    z1(end-3:end) = [];
    z1 = [zStart-diffStart; zStart-diffStart; zStart; zStart; z1];
    axHist.p_handle.Vertices(hitVertices,1) = z1;axHist.shiftTrack(hitTracks) = axHist.shiftTrack(hitTracks) + 1;
end

