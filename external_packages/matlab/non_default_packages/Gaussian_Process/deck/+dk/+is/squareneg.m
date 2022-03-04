function y = squareneg( x, strict )
%
% y = squareneg( x, strict=true )
%
% Check that input x is a square matrix with negative entries.
% If strict is false, then non-positive entries are accepted.
%

    if nargin < 2, strict=true; end
    y = ~dk.is.squarepos( x, ~strict );
    
end
