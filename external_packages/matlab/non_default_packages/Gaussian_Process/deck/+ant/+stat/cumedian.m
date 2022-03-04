function out = cumedian( in, dim )
%
% out = ant.stat.cumedian( in, dim = 1 )
%
% Compute the cumulative sum of in along dim, 
% and return for each sum the index of the term that first exceeds half of the sum.
%
% Note: this doesn't make sense if values change sign.
%
% JH

    assert( ismatrix(in), 'Only on matrices for now.' );
    if nargin < 2, dim = 1; end

    n   = size(in,dim);
    ncs = bsxfun( @rdivide, cumsum(in,dim), sum(in,dim) );
    out = zeros(1,n);
    
    if dim == 1
    for i = 1:n
        out(i) = find( ncs(:,i) > .5-eps(.5), 1, 'first' );
    end
    else
    for i = 1:n
        out(i) = find( ncs(i,:) > .5-eps(.5), 1, 'first' );
    end
    end

end
