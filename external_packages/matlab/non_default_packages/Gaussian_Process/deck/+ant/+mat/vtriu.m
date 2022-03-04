function v = vtriu( A, k )
%
% v = ant.mat.vtriu( A, k=1 )
%
% Extract upper-triangular values of matrix A.
%
% JH

    if nargin < 2, k = 1; end

    n = size(A,1);
    T = triu( true(n), k );
    v = A(T);

end
