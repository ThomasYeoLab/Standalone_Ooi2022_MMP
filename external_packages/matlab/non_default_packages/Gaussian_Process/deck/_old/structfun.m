function out = structfun( fun, val, unif )

    if nargin < 3, unif=false; end
    
    if unif
        out = structfun( fun, val );
    else
        out = structfun( fun, val, 'UniformOutput', false );
    end

end