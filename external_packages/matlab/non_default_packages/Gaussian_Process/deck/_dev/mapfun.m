function out = mapfun( fun, val, unif )
%
% Generalise cellfun/arrayfun to different types of containers.
%
% For cell and arrays, the matlab built-ins are called with non-uniform output,
% and then merged manually into an array if unif is true (this allows objects 
% to be returned, which Matlab doesn't allow, although this assumes these objects
% do _not_ define concatenation methods).
%
% For struct-arrays, the matlab built-in is called on each element. If unif is true
% the output is either a vector (as with structfun) or a cell-array of vectors. If
% unif is false, the output is a struct-array with the same fields as in input.
%
% For containers.Map, the function handle should accept two arguments;
% the first being the key/field, and the second being the associated value.
% The behaviour of unif is similar to cellfun/arrayfun.
%
% JH

    if nargin < 3, unif=true; end
    
    outsize = size(val);
    
    if isempty(val)
        out = {};
        
    elseif isstruct(val)
        
        if isscalar(val)
            out = structfun( fun, val, 'UniformOutput', unif );
        else
            out  = arrayfun( @(x)structfun(fun,x,'UniformOutput',unif), val, 'UniformOutput', false );
            if ~unif, out = reshape( [out{:}], outsize ); end % struct-array
        end
        return;
    
    elseif isa(val,'containers.Map')
        
        K = val.keys();
        n = numel(K);
        
        outsize = [1,n];
        out = cell(outsize);
        for i = 1:n
            k = K{i}; out{i} = fun( k, val(k) );
        end
        
    elseif iscell(val)
        out = cellfun( fun, val, 'UniformOutput', false );        
    else
        out = arrayfun( fun, val, 'UniformOutput', false );
    end
    
    if unif
        out = reshape( [out{:}], outsize );
    end

end

function struct_field_by_field()

    F = fieldnames(val);
    n = numel(F);
    m = numel(val);

    if iscolumn(val)
        outsize = [size(val,1) n];
        index   = @(i,j) i + (j-1)*m;
    elseif isrow(val)
        outsize = [n size(val,2)];
        index   = @(i,j) j + (i-1)*n;
    else
        outsize = [size(val) n];
        index   = @(i,j) i + (j-1)*m;
    end

    out = cell(outsize);
    for i = 1:m
    for j = 1:n
        f = F{j}; out{index(i,j)} = fun( f, val(i).(f) );
    end
    end

end
