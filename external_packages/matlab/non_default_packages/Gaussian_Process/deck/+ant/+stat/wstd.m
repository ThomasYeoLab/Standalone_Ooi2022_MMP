function s = wstd( x, w, dim )
%
% s = ant.stat.wstd( x, w, dim=1 )
%
% Compute weighted std of input sample along specified dimension.
%
% Reference: http://stats.stackexchange.com/a/6536/44129
%
% JH
    
    if nargin < 3
        dim = ant.nsdim(x);
    end

    D = ndims(x);
    N = size(x,dim);
    
    assert(numel(w)==N,'Weight size mismatch.');
    wshape = ones(1,D);
    wshape(dim) = N;
    w = reshape(w,wshape);
    
    M = nnz(w);
    assert( M>1, 'Not enough non-zero weights.' );
    w = w / sum(w(:));
    
    s = sum(bsxfun(@times,x,w),dim);
    s = bsxfun(@minus,x,s).^2;
    s = sqrt( (M/(M-1)) * sum(bsxfun(@times,s,w),dim) );
    
end
