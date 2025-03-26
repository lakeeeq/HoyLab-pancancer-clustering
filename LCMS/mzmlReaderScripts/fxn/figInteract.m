clearvars
clc
clf
f = figure(1);

zoom on
zoom off
a = rand(20,2);
p = scatter(a(:,1),a(:,2),'.');
p.CData = ones(20,1)*[0 0 1];

axHist = figCont;
axHist.h_handle = get(p,'Parent');
axHist.f_handle = f;
axHist.p_handle = p;
axHist.zoomHistory = [axHist.h_handle.XLim axHist.h_handle.YLim];

axHist.xyData = a;
axHist.dataSelectedHistory = false(size(a,1),1);
set(axHist.f_handle,'Units','normalize');
set(axHist.h_handle,'Units','normalize');
% set(p,'HitTest','off');

set(axHist.f_handle,'KeyPressFcn',@(src,evt)myhotkey1p(src,evt,axHist),'KeyReleaseFcn',@(src,evt)myhotkey1r(src,evt,axHist),...
    'WindowButtonMotionFcn','');

