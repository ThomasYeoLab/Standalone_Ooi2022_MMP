function y = posnum( x, strict )
%
% y = dk.is.posnum( x, strict=true )
%
% Check if input is a positive number.
%

    if nargin < 2, strict=true; end
    if strict
        y = dk.is.number(x) && (x > 0);
    else
        y = dk.is.number(x) && (x >= 0);
    end
end