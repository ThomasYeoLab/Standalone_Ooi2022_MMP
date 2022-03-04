function [q,r] = divmod(a,b)
%
% [q,r] = dk.num.divmod(a,b)
%
% Quotient and remainder in one operation, such that:
%
%   a = q*b + r;
%
% Particularly useful for integer divisions.
% Works as expected for negative inputs (but b should be non-zero).
%
% Example:
%   quorem(5,3) => q=1, r=2
%   quorem(1,3) => q=0, r=1
%   quorem(-1,3) => q=-1, r=2
%   quorem(-1,-3) => q=0, r=-1
%
% JH

    assert( abs(b) > eps, 'Divisor should be positive.' );

    r = mod(a,b);
    q = (a-r)/b;
    
end