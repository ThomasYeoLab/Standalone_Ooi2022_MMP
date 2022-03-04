function C = sub( A, B )
    C = bsxfun( @minus, A, B );
end