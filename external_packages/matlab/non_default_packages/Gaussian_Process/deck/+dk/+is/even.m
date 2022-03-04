function varargout = even(varargin)
%
% y = even(x)
% [y1,y2,...] = even(x1,x2,...)
%
% Check if input is/are even integers. 
% Accepts matrices in input.

    varargout = dk.mapfun( @(x) dk.num.modeq(x,2,0), varargin, false );
end