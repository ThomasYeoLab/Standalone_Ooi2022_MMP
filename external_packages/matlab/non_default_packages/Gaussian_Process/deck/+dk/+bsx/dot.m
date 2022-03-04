function C = dot( A, B, dim )
%
% C = dk.bsx.dot( A, B, dim )
%
% A vectorized version of the dot-product (called "singleton-expansion" in Matlab).
%
% Input:
%   A, B numeric arrays.
%   dim (default: 1) the dimension reduced by the dot product.
%
% Output:
%   C is an array of size max(size(A),size(B)), with the constraint size(C,dim) == 1.
%
% JH

    if nargin < 3, dim = 1; end
    C = sum(bsxfun(@times,A,B),dim);

end
