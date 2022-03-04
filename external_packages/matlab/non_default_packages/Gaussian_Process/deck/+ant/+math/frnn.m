function k = frnn( x, q, r )
%
% k = ant.math.frnn( x, q, r )
%
% Fixed-radius near neighbours.
% Find all points in x within a radius r of query point q.
% Points are assumed to be given in row, that is:
%   x should be a nxd matrix, with d the #of dimensions
%   q should be a mxd matrix
%
% r should either be a positive scalar, or a 1xm vector.
% Output k is a cell of row-indices in x (or a vector if m=1).
%
% This method is particularly suited to cases where x is huge, and q is small.
%
% JH

    r = r(:)';
    lo = dk.bsx.sub( q, r );
    up = dk.bsx.add( q, r );

    n = size(q,1);
    k = cell(1,n);
    if isscalar(r), r=r*ones(1,n); end
    
    % filter points within an L1 distance of r
    for i = 1:n
        k{i} = find(all( dk.bsx.gt(x,lo(i,:)) & dk.bsx.lt(x,up(i,:)), 2 ));
    end
    
    % remove points further than r
    sqr = @(y) y.*y;
    for i = 1:n
        k{i} = k{i}( sum(dk.bsx.sub(x(k{i},:),q(i,:)).^2,2) < r(i)*r(i) );
    end
    
    % unwrap singletons
    if n == 1, k = k{1}; end
    
end