function y = number(varargin)
%
% y = number(x)
% y = number(x1, x2, ...)
%
% Check if input(s) is/are number(s) (incl complex).
% Does not accept inf/nan.
%   
% JH

    y = dk.mapfun( @ducktest, varargin, true );
    
end

function t=weaktest(x)
    t = isscalar(x) && isnumeric(x);
end

function t=fulltest(x)
    t = isscalar(x) && isnumeric(x) && ~isinf(x) && ~isnan(x);
end

function t=ducktest(x)
    try
        t = isscalar(x) && isnumeric(x) && (x*0 == 0);
    catch 
        t = false;
    end
end
