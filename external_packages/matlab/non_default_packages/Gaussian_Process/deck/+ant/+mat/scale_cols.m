function Y = scale_cols( X, v )

    if isscalar(v)
        v = v*ones(1, size(X,2) );
    elseif iscolumn(v)
        v = v';
    end
    
    Y = bsxfun( @times, X, v );

end
