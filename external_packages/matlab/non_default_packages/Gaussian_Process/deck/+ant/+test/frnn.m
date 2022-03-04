function nns_fr( x, q, r )

    r = r(:)';
    n = size(q,1);
    if isscalar(r), r=r*ones(1,n); end
    
    f1 = @rangesearch;
    f2 = @ant.math.frnn;
    f3 = @impl_exhaustive;
    
    % first, check that the results are correct
    k1 = f1( x, q, r );
    k2 = f2( x, q, r );
    k3 = f3( x, q, r );
    
    for i = 1:n
        assert( all(k1{i} == k2{i}), 'f2 mismatch' );
        assert( all(k1{i} == k3{i}), 'f3 mismatch' );
    end
    
    Nr = 50;
    dk.timeit( Nr, @ant.math.frnn, x, q, r );

end

function k = impl_exhaustive(x,q,r)
    n = size(q,1);
    k = cell(1,n);
    for i = 1:n
        k{i} = find( sum(dk.bsx.sub(x,q(i,:)).^2,2) < r(i)*r(i) );
    end
end
