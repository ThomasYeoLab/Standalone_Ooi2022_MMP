function [k,v,dim] = reduce( fun, ind, val, unif, dim )
%
% [k,v,dim] = reduce( fun, ind, val, unif=true, dim=[] )
%
% fun: function handle
% ind: indices (Nx1 vector or Nxd matrix)
% val: a scalar, or any container with N elements 
% unif: if true (default) v is a vector, otherwise a cell
% dim: dimensions used to map subindices to plain indices, 
%      or determine valid indices (default: [])
%
% Apply fun to the set of values associated with the same index, and return
% a pair (k,v) with the value associated with that index. This can be seen
% as generalisation of accumarray or splitapply.
%
% Function should accept two inputs:
%   1. The index for the current group
%   2. The corresponding values (scalar, cell or matrix)
%
% JH

    if nargin < 4, unif=true; end
    if nargin < 5, dim=[]; end
    
    assert( dk.is.fhandle(fun), 'fun should be a function handle' );
    assert( ismatrix(ind), 'ind should be a matrix' );
    
    % match ind and val dimensions
    [n,d] = size(ind);
    if iscell(val)
        assert( numel(val)==n, 'Number of elements in val should match number of rows in ind.' );
    else
        assert( isscalar(val) || size(val,1)==n, 'Mismatch between number of rows in val and ind.' );
    end
    
    % determine and format output dimensions
    if isempty(dim)
        dim = max(ind,[],1);
    end
    dim = uint64(dim(:)');
    
    % convert subs to indices
    if d > 1
        assert( d==numel(dim), 'Size mismatch between ind and dim.' );
        assert( all(ind(:) >= 1), 'Indices should be positive integers.' );
        
        s = cumprod([1,dim]);
        ind = ind * s(1:end-1)';
    end

    % filter valid indices and sort them
    valid = ind <= prod(dim);
    ind = uint64(ind(valid));
    [ind,ord] = sort(ind(:));

    % process values accordingly
    if iscell(val)
        val = val(valid);
        val = val(ord);
        vget = @(x) val(x);
    elseif isscalar(val)
        vget = @(x) val;
    else
        val = val(valid,:);
        val = val(ord,:);
        vget = @(x) val(x,:);
    end
    
    % segment indices
    strides = 1 + [0;find(ind(2:end) - ind(1:end-1));n];
    k = double(ind(strides(1:end-1)));
    m = numel(k);
    if unif
        v = nan(m,1);
        for i = 1:m
            p = strides(i):(strides(i+1)-1);
            v(i) = fun(k(i),vget(p));
        end
    else
        v = cell(m,1);
        for i = 1:m
            p = strides(i):(strides(i+1)-1);
            v{i} = fun(k(i),vget(p));
        end
    end

end