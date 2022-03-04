function rowid = ubound( vals, query )
%
% rowid = ant.math.ubound( vals, query )
%
% Inputs:
%   - vals is a NxM matrix with values sorted ascending in each column
%   - query is a 1xM vector
%
% Output:
%   rowid is a 1xM vector containing the last column indices such that:
% 
%   k = sub2ind( size(vals), first, 1:M );
%   vals(k) > query if query < V(end,:)
%
%
% This method uses binary search for an efficient search within the columns of the value matrix.
% The price to pay for this efficiency is that elements within each column have to be sorted.
% This can be used eg for distribution sampling.
%
% 
% Example:
%
%   n = 5; 
%   m = 7;
%   v = cumsum(rand(n,m)); v = [zeros(1,m);bsxfun( @rdivide, v, v(end,:) )]
%   q = rand(1,m)
%   r = ant.math.ubound( v, q )
%
% TODO: extend this to arbitrary dimensions.
% TODO: implement this in C++

    assert( ismatrix(vals) && ismatrix(query), 'Inputs should be matrices.' );
    
    [nr,nc] = size(vals);
    nq = numel(query);
    
    % input value is a row vector, swap sizes
    if nr == 1
        nr = nc; nc = 1;
        
    % input value is a column vector, transpose it
    elseif nc == 1
        vals = transpose(vals);
    end
    
    % input query is scalar, repeat it for each input column
    if nq == 1
        query = query * ones(1,nc); nq = nc;
        
    % input query is a vector, make sure it is a row    
    else
        query = transpose(query(:));
    end
    
    % input value has only one column, all offsets are 0
    if nc == 1
        idoff = zeros(1,nq);
        
    % otherwise the offset is different for each column
    else
        idoff = nr * (0:nc-1);
    end 
    
    rowid = ones(1,nq);
    count = nr * ones(1,nq);
    
    while any(count > 0)
        
        step = floor(count / 2);
        mask = (count > 0) & (query >= vals( rowid+step + idoff ));
         
        rowid( mask) = rowid(mask) + step(mask) + 1;
        count( mask) = count(mask) - step(mask) - 1;
        count(~mask) = step(~mask);
        
    end

end
