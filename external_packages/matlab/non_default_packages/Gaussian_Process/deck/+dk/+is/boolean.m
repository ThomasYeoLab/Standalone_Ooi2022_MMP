function y = boolean(varargin)
%
% y = boolean(x)
% y = boolean(x1, x2, ...)
%
% Check if input(s) is/are boolean.
%

    y = dk.mapfun( @(x) isscalar(x) && islogical(x), varargin, true );
end