function S = simplex( d, demean )
%
% S = ant.geom.simplex( d, demean=false )
%
% Create a unit simplex in dimension d.
% If demean is true, the centre of the simplex is put at 0.
% Otherwise, the first vertex is 0.
%
% JH

    if nargin < 2, demean = false; end

    S = zeros( d+1, d );
    U = 0;
    A = zeros(1,d);

    for n = 1:d
        S(n+1,:) = A/n;
        S(n+1,n) = S(n+1,n) + sqrt(1-U);

        A = A + S(n+1,:);
        U = (n/(n+1))^2 * (1-U);
    end

    if demean
        S = dk.bsx.sub( S, mean(S,1) );
    end

end
