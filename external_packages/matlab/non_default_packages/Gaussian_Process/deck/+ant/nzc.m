function n = nzc(x)
%
% n = ant.nzc(x)
%
% Number of zero-crossings in input vector x.
%
% JH

    n = diff(x(:));
    n = nnz( n(1:end-1) .* n(2:end) <= 0 );

end