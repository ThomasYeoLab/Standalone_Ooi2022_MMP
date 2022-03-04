function Y = rescale( X, range, dim, method )
%
% Y = ant.math.rescale( X, range=[0,1], dim=ns )
%
% Rescale X linearly along dimension dim within specified range.
% If dim is not specified, the rescaling occurs along the first non-singleton dimension.
%
% JH

    if nargin < 2, range = [0 1]; end
    if nargin < 3, dim = ant.nsdim(X); end
    if nargin < 4, method = 'linear'; end
    
    xmin = min(X,[],dim);
    xmax = max(X,[],dim);
    
    lo = range(1);
    up = range(2);
    
    switch lower(method)
    
        case 'linear'
            Y = (up-lo)*dk.bsx.sub(X,xmin);
            Y = lo + dk.bsx.rdiv( Y, max( xmax-xmin, eps ) );
            
        otherwise
            error('Unknown method "%s".',method);
        
    end
    
end
