function pairing(n,nmax)

    if nargin < 2, nmax=1e4; end
    if nargin < 1, n=1e5; end
    
    method = {'cantor','szudzik','peter','hagen'};
    
    i = randi( nmax, n, 1 );
    j = randi( nmax, n, 1 );
    
    m = numel(method);
    for c = 1:m
        mc = method{c};
        k = ant.math.pairing( i, j, mc );
        [ii,jj] = ant.math.unpairing( k, mc );
        
        e = (i ~= ii) | (j ~= jj);
        if any(e)
            fprintf( '%s pairing: %d error(s)\n', mc, nnz(e) );
        else
            fprintf( '%s pairing: ok\n', mc );
        end
    end

end