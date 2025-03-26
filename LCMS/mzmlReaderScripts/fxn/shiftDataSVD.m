function shiftDataSVD(axHist,svdTimeShifted)
%if trueRight is 'true', then will shift selected data to the right
%if "false', then shift selected data to the left
selectedTracks = find(axHist.dataSelectedHistory(:,end));
for i = 1:numel(svdTimeShifted)
    if svdTimeShifted(i) == 0
        continue
    end
    hitFaces = axHist.xyData.faceAssigned==selectedTracks(i);
    hitVertices = false(axHist.xyData.noFace*4,1);
    for j = find(hitFaces)
        hitVertices(axHist.p_handle.Faces(j,:)) = true;
    end
    
    z1 = axHist.p_handle.Vertices(hitVertices);
    if svdTimeShifted(i)>0
        for j = 1:abs(svdTimeShifted(i))
            diffStart = z1(3)-z1(2);
            zStart = z1(1);
            z1(end-3:end) = [];
            z1 = [zStart-diffStart; zStart-diffStart; zStart; zStart; z1];
        end
    else
        for j = 1:abs(svdTimeShifted(i))
            diffEnd = z1(end-1)-z1(end-2);
            zEnd = z1(end);
            z1(1:4) = [];
            z1 = [z1; zEnd; zEnd; zEnd+diffEnd; zEnd+diffEnd];
        end
        
    end
    axHist.p_handle.Vertices(hitVertices,1) = z1;
    
    %     axHist.p_handle.Vertices(hitVertices) = axHist.p_handle.Vertices(hitVertices) - svdTimeShifted(i)*min(diff(axHist.xyData.timeWindow));
        axHist.shiftTrack(selectedTracks(i)) = axHist.shiftTrack(selectedTracks(i)) + svdTimeShifted(i);
    
    
    
end