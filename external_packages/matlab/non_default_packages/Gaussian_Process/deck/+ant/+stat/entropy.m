function [Hx,Px] = entropy( x, nbins )
%
% [Hx,Px] = ant.stat.entropy( x, nbins )
%
% Estimate entropy using nbins histogram.
%
% JH

    if nargin < 2, nbins = 100; end

    % Reshape, rescale and bin data
    x = x(:);
    n = numel(x);
    
    l = min(x);
    u = max(x);
    
    x = 1 + floor( nbins*(x - l)/max(eps,u-l) );
    m = nbins+1;
    
    % Compute entropy
    Px = accumarray( x, 1, [m,1] )/n;
    Hx = max( 0, -dot( Px, log2(Px+eps) ) );

end