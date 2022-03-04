function Y = scale_rows( X, v )

    if isscalar(v)
        v = v*ones( size(X,1) ,1);
    elseif isrow(v)
        v = v';
    end
    
    Y = bsxfun( @times, X, v );

end
