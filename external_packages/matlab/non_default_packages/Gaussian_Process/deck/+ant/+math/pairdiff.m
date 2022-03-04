function D = pairdiff( A, B )
%
% D = ant.math.pairdiff( A, B )
%
% Matrix of pairwise differences between elements of A and B (both vectors).
% Output is antisymmetric.
%
% JH

    if nargin < 2, B = A; end

    A = A(:);
    B = B(:)';
    D = bsxfun( @minus, A, B );

end
