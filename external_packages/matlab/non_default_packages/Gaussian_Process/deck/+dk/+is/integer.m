function y = integer(varargin)
%
% y = integer( x )
% y = integer( x1, x2, ... )
%
% Check if inputs are (scalar) integers.
%
% JH

    y = dk.is.number(varargin{:}) & dk.mapfun( @(x) dk.num.modeq(x,1,0), varargin, true );
    
end
