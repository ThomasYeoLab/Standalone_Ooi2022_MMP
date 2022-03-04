function yes = isperm(p)
%
% yes = dk.num.isperm(p)
%
% Checks whether input vector p is a permutation.
%
% Input:
%   p a permutation vector or matrix
%   If p has N elements, then p should contain a permutation of 1:N
%
% JH

    len    = numel(p);
    counts = accumarray( p(:), 1, [len,1] );
    yes    = all(counts == 1);
end
