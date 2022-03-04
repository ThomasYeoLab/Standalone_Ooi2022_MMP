function [o,r] = band_overlap( a, b )
%
% [o,r] = ant.util.band_overlap( band1, band2 )
%
%   o   width of overlap (>= 0)
%   r   overlap ratio relative to smallest bandwidth
%
% JH

    w = min( a(2)-a(1), b(2)-b(1) );
    u = min(a(2),b(2));
    b = max(a(1),b(1));
    o = max( u-b, 0 );
    r = o/max(eps,w);

end