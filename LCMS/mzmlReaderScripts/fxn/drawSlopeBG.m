function y_out = drawSlopeBG(x_in,y_in,x_out)
%%%input as column vector
X = [ones(length(x_in),1) x_in];
X_out = [ones(length(x_out),1) x_out];
b = X\y_in;

y_out = X_out*b;