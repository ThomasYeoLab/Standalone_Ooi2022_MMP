function out = arrayfun( fun, val, unif )

    if nargin < 3, unif=false; end
    
    if unif
        out = arrayfun( fun, val );
    else
        out = arrayfun( fun, val, 'UniformOutput', false );
    end

end