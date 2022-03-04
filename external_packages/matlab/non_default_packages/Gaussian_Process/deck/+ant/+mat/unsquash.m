function mat = unsquash( mat, rev )
%
% mat = ant.mat.unsquash( mat, rev )
%
% Reverse transformation of ant.mat.squash.
%
% See also: ant.mat.squash
%
% JH

    assert( all(size(mat) == rev.outsize), 'Bad input.' );
    
    rperm(rev.perm) = 1:rev.nd;
    mat = permute( reshape(mat,rev.tmpsize), rperm );

end
