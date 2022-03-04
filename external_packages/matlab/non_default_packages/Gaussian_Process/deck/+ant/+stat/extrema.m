function [m,M] = extrema( X, dim )
%
% [m,M] = ant.stat.extrema( X, dim )
%
% Compute extrema (min,max) on input data X along dimension dim.
%
% JH

    if nargin < 2, dim = 1; end
    
    m = min(X,[],dim);
    M = max(X,[],dim);

end
