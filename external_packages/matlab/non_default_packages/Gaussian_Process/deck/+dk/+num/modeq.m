function t = modeq(x,n,p)
%
% t = modeq(x,n,p)
% 
% Test for equality:
%   x = p [mod n]
%
% Output is logical.
% x may be a numeric array, in which case the output is a logical array of the same size.
% Otherwise, the output is a scalar boolean (false).
% 
% JH

    if isnumeric(x)
        t = mod(x,n) == p;
    else
        t = false;
    end
end