function [Hxy,Hx,Hy] = joint_entropy( x, y, nbins )
%
% [Hxy,Hx,Hy] = ant.stat.joint_entropy( x, y, nbins )
%
% Estimates joint entropy between sequences x and y (assuming same number of elements and range of value).
% You can normalise x and y prior to this if they vary with different mean/std.
% The estimate relies on a histogram with nbins spanning the range of variation of x and y.
%
% From the outputs, you can compute:
%   - Mutual information (MI): Hx + Hy - Hxy
%   - Normalised mutual information: MI/sqrt( Hx*Hy )
%   - Normalised variation information: 2 - (Hx+Hy)/Hxy
%   - Conditional entropies: H(x|y)=Hxy-Hy 
%
% See also: ant.stat.entropy
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
    
    % Entropy function
    entfun = @(z) max( 0, -dot( z, log2(z+eps) ) );
    
    % Joint-entropy
    idx = 1:n;
    Mx  = sparse(x,idx,1,m,n,n); % transposed for faster computation
    My  = sparse(idx,y,1,n,m,n);
    Hxy = entfun(nonzeros(Mx*My/n));

    % Marginal entropies
    Hx = entfun(full(mean(Mx,2)));
    Hy = entfun(full(mean(My,1)));
    
end