function [bounds,rtype] = range( x, rtype, bounds )
%
% [bounds,rtype] = ant.img.range( x, rtype='auto', bounds=[] )
%
% Estimage color range for display.
% x can be either an image, or a cell of images.
%
% See also: dk.num.range
%
% JH

    if nargin < 2, rtype='auto'; end
    if nargin < 3, bounds=[]; end

    if iscell(x)
        n = numel(x);
        B = nan(1,2);
    
        for i = 1:n
            tmp = dk.num.range( x{i}, rtype, bounds );
            B(1) = min(tmp(1),B(1));
            B(2) = max(tmp(2),B(2));
        end
        
        % final run to honour rtype
        [bounds,rtype] = dk.num.range( [], rtype, B );
    else 
        [bounds,rtype] = dk.num.range( x, rtype, bounds );
    end

end
