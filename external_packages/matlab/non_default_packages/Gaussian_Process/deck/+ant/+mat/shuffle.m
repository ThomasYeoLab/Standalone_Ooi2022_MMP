function [M,r,c] = shuffle( M )
%
% [B,r,c] = ant.mat.shuffle( A )
%
% Shuffle the rows and columns of a matrix.
% Additional outputs are the inverse permutations, such that B(r,c) == A.
%
% JH

    assert( ismatrix(M), 'Input should be a matrix.' );
    [nr,nc] = size(M);

    % shuffle rows and columns
    r = randperm(nr);
    c = randperm(nc);
    M = M(r,c);
    
    % reverse the permutations
    r(r) = 1:nr;
    c(c) = 1:nc;
    
end
