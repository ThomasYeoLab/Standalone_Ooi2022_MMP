function y = filter( x, ignoreInf )
%
% y = dk.num.filter( x, ignoreInf=true )
%
% Filter numeric values from x, ignoring NaNs and Inf
%
% JH

    if nargin < 2, ignoreInf=true; end
    
    if ignoreInf
        y = isinf(x) | isnan(x);
    else
        y = isnan(x);
    end
    y = x(~y);

end