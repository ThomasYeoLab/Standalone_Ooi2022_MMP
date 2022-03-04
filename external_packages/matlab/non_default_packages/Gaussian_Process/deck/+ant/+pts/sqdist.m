function d = sqdist( a, b )
%
% d = ant.pts.sqdist( a )
% d = ant.pts.sqdist( a, b )
%
% Fast squared euclidean distance, or L2 norm.
% Points should be IN ROWS.
%
% JH

    if nargin > 1
        a = dk.bsx.sub(a,b);
    end
    d = dot(a,a,2);
    
end