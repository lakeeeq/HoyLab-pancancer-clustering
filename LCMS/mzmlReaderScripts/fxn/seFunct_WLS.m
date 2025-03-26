function f = seFunct_WLS(x,PM,LHS,minX,c,m,Sres,sumW,Xmean,Sxx,Wmax,wlsPower)

if x<minX
    f = ((c+m*x) + PM*Sres*sqrt(1/Wmax + 1/sumW + (x - Xmean).^2/Sxx) - LHS)^2;
else
    f = ((c+m*x) + PM*Sres*sqrt(x^wlsPower + 1/sumW + (x - Xmean).^2/Sxx) - LHS)^2;
end