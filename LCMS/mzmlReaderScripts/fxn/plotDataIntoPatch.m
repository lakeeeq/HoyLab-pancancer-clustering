function plotDataIntoPatch(dataAligned,timeWindow,fileGrp)
noData = size(dataAligned,1);
noT = numel(timeWindow);
%%%normalize to max per line
for i = 1:noData
    dataAligned(i,:) = dataAligned(i,:)./max(dataAligned(i,:));
end
%%%%normalize to max of all
% dataAligned = dataAligned/max(max(dataAligned));


dataAligned_color = round(dataAligned*63)+1;
yWidth = 1/noData;
yBase = [0:yWidth:1];
fileGrp(end+1) = fileGrp(end);
fg_unique = unique(fileGrp);
for i = 1:numel(fg_unique)
    yBase(fileGrp==fg_unique(i)) = yBase(fileGrp==fg_unique(i)) + 5*yWidth*(i-1);
end

xdata = [];
ydata = [];
cdata = [];
for i = 1:noData
    for j = 1:noT-1%%%end-1
        xdata(:,end+1) = [timeWindow(j) timeWindow(j) timeWindow(j+1) timeWindow(j+1)];
        ydata(:,end+1) = [yBase(i) yBase(i)+yWidth yBase(i)+yWidth yBase(i)];
        cdata(:,end+1) = [dataAligned_color(i,j) dataAligned_color(i,j) dataAligned_color(i,j+1) dataAligned_color(i,j+1)];
    end
end

cla
patch(xdata,ydata,cdata,'EdgeAlpha', 0);
aa = gca;
aa.YTick = yBase;
aa.YTickLabel = 1:noData;
% yticks('');
colormap('parula');
