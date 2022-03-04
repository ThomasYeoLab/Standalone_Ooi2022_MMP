function y = posint( x, strict )
%
% y = dk.is.posint( x, strict=true )
%
% Check if input is a positive integer.
%

    if nargin < 2, strict=true; end
    if strict
        y = dk.is.integer(x) && (x > 0);
    else
        y = dk.is.integer(x) && (x >= 0);
    end
end