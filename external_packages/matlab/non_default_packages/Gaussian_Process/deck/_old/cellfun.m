function out = cellfun( fun, val, unif )

    if nargin < 3, unif=false; end
    
    if unif
        out = cellfun( fun, val );
    else
        out = cellfun( fun, val, 'UniformOutput', false );
    end

end