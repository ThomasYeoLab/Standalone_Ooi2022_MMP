function y = round( x, n )
%
% y = dk.num.round( x, n=0 )
%
% Round to a given decimal place 

    if nargin < 2
        y = round(x);
    else
        y = 10^n;
        y = round( y*x ) / y;
    end

end
