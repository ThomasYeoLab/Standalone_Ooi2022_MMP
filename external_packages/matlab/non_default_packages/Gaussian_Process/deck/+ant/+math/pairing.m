function k = pairing( i, j, method )
%
% k = ant.math.pairing( i, j, method )
%
% Pairing methods:
%   cantor, szudzik, peter, hagen
%
% See also: ant.math.unpairing, ant.math.sympair
%
% JH

    i = i-1;
    j = j-1;

    switch lower(method)
        
        case 'cantor'
            k = i + j;
            k = j + k.*(k+1)/2;
            
        case 'szudzik'
            m = i > j;
            k = j;
            
            k(m) = k(m) + i(m).^2;
            
            m = ~m;
            k(m) = k(m) + j(m).^2 + i(m);
            
        case 'peter'
            s = max(i,j);
            t = min(i,j);
            k = s.^2 + 2*t + (t ~= j);
            
        case 'hagen'
            s = max(i,j);
            t = min(i,j);
            f = mod(s,2) == 0;
            f = (f | (t ~= i)) & (~f | (t ~= j));
            k = s.^2 + 2*t + f;
            
        otherwise
            error( 'Unknown method: %s', method );
            
    end

end