function n = lnorm( X, p, dim )
% n = lnorm( X, p, dim )
%
% Compute Lebesgue measure of order p along dimension dim.
%
% INPUTS:
%
%    X: numeric array
%    p: scalar int (default 2)
%  dim: dimension along which to compute the norm (default 1)
%
% OUTPUT:
%   n is an array of same size as X, except that size(n,dim) == 1.
%
% JH

    if nargin < 3, dim=1; end
    if nargin < 2, p=2; end
    
    switch p
        case 1
            n = sum( abs(X), dim );
        case 2
            n = sqrt(dot( X, conj(X), dim ));
        otherwise
            assert( isscalar(p) && dk.is.integer(p), 'Bad order p.' );
            error( 'Not implemented for p=%d', p );
    end

end
