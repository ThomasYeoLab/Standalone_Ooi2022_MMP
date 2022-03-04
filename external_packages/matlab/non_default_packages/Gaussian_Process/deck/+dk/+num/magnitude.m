function [m,t] = magnitude( x, n )
%
% [m,t] = dk.num.magnitude( x, n=1 )
%
% Order of magnitude.
%
% First ouput is the most significant decimal place; the base-10 exponent 
% corresponding to the "highest" digit of x. Second output is the base-10 
% rounding threshold to retain n digits of the input.
%
% Example:
%   x = 12.345678;
%   [m,t] = dk.num.magnitude(x,3)
%   assert( abs( x - t*round(x/t) ) < t )
%
% JH

    if nargin < 2, n=1; end

    % most significant decimal place
    x = abs(x);
    if x > eps
        m = floor(log10(x));
    else 
        m = -inf;
    end
    
    % remove n from that
    t = 10^(m-n);

end
