function cmat = symrand(cmat)
%
% cmat = ant.mat.symrand(cmat)
%
% Symmetric randomisation (shuffle edges while preserving symmetry).
%
% JH

    assert( dk.is.square(cmat), 'Expected square matrix in input.' );
    
    idx = find(tril( true(size(cmat)), -1 ));
    ord = randperm(length(idx));

    cmat(idx) = cmat(idx(ord));
    cmat = transpose(cmat);
    cmat(idx) = cmat(idx(ord));
    cmat = transpose(cmat);

end