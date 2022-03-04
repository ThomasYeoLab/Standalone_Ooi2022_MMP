function [KL,Px,Py] = relative_entropy( x, y, nbins )
%
% [KL,Px,Py] = ant.stat.relative_entropy( x, y, nbins )
%
% Estimate relative entropy (aka KL divergence) between sequences x and y.
%
% See also: ant.stat.joint_entropy, ant.stat.entropy
%
% JH

    if nargin < 3, nbins = 100; end

    % Turn inputs into columns
    assert( numel(x) == numel(y) ); % check they have the same number of elements
    n = numel(x);
    x = x(:);
    y = y(:);
    
    % Get bin indices
    l = min(min(x),min(y));
    u = max(max(x),max(y));
    d = max( u-l, eps );
    
    x = 1+floor( nbins*(x-l)/d );
    y = 1+floor( nbins*(y-l)/d );
    m = nbins+1;
    
    % Get marginal entropies
    Px = accumarray( x, 1, [m,1] )/n;
    Py = accumarray( y, 1, [m,1] )/n;

    % Compute KL divergence
    KL = max( 0, -dot( Px, log2(Py+eps)-log2(Px+eps) ) );
    
end