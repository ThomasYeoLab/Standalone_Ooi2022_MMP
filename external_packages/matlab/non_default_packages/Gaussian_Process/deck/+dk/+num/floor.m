function y = floor( x, n )
%
% y = dk.num.floor( x, n=0 )
%
% Floor to a given decimal place.
% This is equivalent to "truncating" to n decimal places.

    if nargin < 2
        y = floor(x);
    else
        y = 10^n;
        y = floor( y*x ) / y;
    end

end
