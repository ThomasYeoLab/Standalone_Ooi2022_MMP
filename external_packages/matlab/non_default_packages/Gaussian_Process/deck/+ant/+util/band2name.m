function n = band2name(b,fmt)
%
% n = ant.util.band2name( b, fmt='%.0f-%.0f' )
%
%   Convert a cell array of frequency bands (1x2 vectors) to a cell array of strings.
%
%   If b is cell, n is cell,
%   If b is vector, n is string.
%
% JH

    if nargin < 2, fmt = '%.0f-%.0f'; end
    
    if iscell(b)
        n = dk.mapfun( @(x) sprintf(fmt,x(1),x(2)), b );
    else
        n = sprintf(fmt,b(1),b(2));
    end

end