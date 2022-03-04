function c = hot( n, sign )
%
% c = hot( n=64, sign=1 )
%
% Hot colormap finishing at yellow instead of white, and with a signed version.
% 
% If sign > 0, the values go from black to yellow through red.
% If sign < 0, the values go from cyan to black through blue.
% If sign == 0:
%   - the positive part is the same as s > 0;
%   - the negative part is the same as s < 0.
%
% JH

    if nargin < 2, sign=1; end
    if islogical(sign)
        if sign
            sign = 0;
        else
            sign = 1;
        end
    end

    n  = n-1;
    n1 = floor(2*n/3);
    n2 = n-n1;
    
    assert( n1*n2 > 0, 'Number of colorpoints is too small.' );

    r = [ (1:n1)/n1, ones(1,n2) ]';
    g = [ zeros(1,n2), ((1:n1)/n1).^2 ]';
    b = zeros(n2+n1,1);
    
    cpos = [ r, g, b ];
    cneg = flipud([ b, g, r ]);
    
    if sign > 0
        c = [0 0 0;cpos];
    elseif sign < 0
        c = [cneg;0 0 0];
    else
        c = [cneg;0 0 0;cpos];
    end
    
    if nargout == 0, dk.cmap.show(c); end
    
end