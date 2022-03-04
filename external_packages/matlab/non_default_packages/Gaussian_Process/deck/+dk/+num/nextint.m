function y = nextint(x)
%
% y = nextint(x)
%
% Short-hand for floor(x)+1 
% Note that this is not equivalent to ceil; in particular, nextint is not idempotent.

    y = floor(x)+1;
end