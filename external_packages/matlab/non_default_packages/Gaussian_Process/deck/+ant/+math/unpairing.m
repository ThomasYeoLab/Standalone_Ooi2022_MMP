function [i,j] = unpairing( k, method )
%
% [i,j] = ant.math.unpairing( k, method )
%
% Unpairing methods:
%   cantor, szudzik, peter, hagen
%
% See also: ant.math.pairing, ant.math.symunpair
%
% JH

    switch lower(method)
        case 'cantor'
            w = sqrt(8*k+1);
            w = floor((w-1)/2);
            t = w.*(w+1)/2;
            
            j = k-t;
            i = w-j;
            
        case 'szudzik'
            s = floor(sqrt(k));
            m = k < s.*(s+1);
            i = s;
            j = s;
            
            j(m) = k(m) - s(m).^2;
            m = ~m;
            i(m) = k(m) - s(m).*( s(m) + 1 );
            
        case 'peter'
            s = floor(sqrt(k));
            r = k - s.^2;
            t = floor(r/2);
            m = mod(r,2) == 0;
            i = s;
            j = s;
            
            j(m) = t(m);
            m = ~m;
            i(m) = t(m);
            
        case 'hagen'
            s = floor(sqrt(k));
            t = k - s.^2;
            t = floor(t/2);
            m = mod(k,2) == 0;
            i = s;
            j = s;
            
            j(m) = t(m);
            m = ~m;
            i(m) = t(m);
            
        otherwise
            error( 'Unknown method: %s', method );
    end
    
    i = i+1;
    j = j+1;

end