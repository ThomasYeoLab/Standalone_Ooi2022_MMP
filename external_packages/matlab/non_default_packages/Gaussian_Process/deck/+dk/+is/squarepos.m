function y = squarepos( x, strict )
%
% y = squarepos( x, strict=true )
%
% Check that input x is a square matrix with positive entries.
% If strict is false, then non-negative entries are accepted.
%

    if nargin < 2, strict=true; end

    y = dk.is.square(x) && isnumeric(x);
    if nargin > 1 && strict
        y = y && all( x(:) > 0 );
    else
        y = y && all( x(:) >= 0 );
    end
    
end
