function varargout = odd(varargin)
%
% y = odd(x)
% [y1,y2,...] = odd(x1,x2,...)
%
% Check if input is/are odd integers.
% Accepts matrices in input.

    varargout = dk.mapfun( @(x) dk.num.modeq(x,2,1), varargin, false );
end