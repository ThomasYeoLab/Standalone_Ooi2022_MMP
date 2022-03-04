function C = sym2col( S, nodiag )
%
% C = ant.mat.sym2col( S, nodiag=false )
%
% Converts input symmetric matrix S to a column representation containing the lower-triangular data.
% The order of elements in the output column corresponds to the vertical concatenation of:
%   - first column elements
%   - second column elements under diagonal
%   - third column elements under diagonal
%   - etc.
%
% S can be a square matrix, or a volume of square slices.
%   size(S,1)=size(S,2)=n   and   size(S,3)=3
%
% nodiag=true : diagonal elements are excluded              output is n(n+1)/2-by-s
% nodiag=false: diagonal elements are included (default)    output is n(n-1)/2-by-s
%
% JH

    assert( size(S,1) == size(S,2), 'S should be square.' );
    assert( ndims(S) <= 3, 'S should be a matrix or a volume.' );
    if nargin < 2, nodiag=false; end

    n = size(S,1);
    s = size(S,3);
    
    if nodiag
        M = tril(true(n),-1);
        m = n*(n-1)/2;
    else
        M = tril(true(n));
        m = n*(n+1)/2;
    end
    
    C = reshape( S(repmat(M,[1 1 s])), m, s );

end
