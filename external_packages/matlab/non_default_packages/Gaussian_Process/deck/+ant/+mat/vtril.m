function v = vtril( A, k )
%
% v = ant.mat.vtril( A, k=1 )
%
% Extract lower-triangular values of matrix A.
%
% JH

    if nargin < 2, k = 1; end

    n = size(A,1);
    T = tril( true(n), -k );
    v = A(T);

end
