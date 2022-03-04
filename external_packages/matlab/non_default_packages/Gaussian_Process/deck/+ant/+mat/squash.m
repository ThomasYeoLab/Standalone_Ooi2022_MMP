function [mat,rev] = squash( mat, dim )
%
% mat = ant.mat.squash( mat, dim )
%
% Whatever the dimensions of input mat, reshape it as a 2D array where the first dimension
% corresponds to the second input.
%
% * If dim is unspecified, then the first non-singleton dimension is selected.
% * If dim is scalar, then the size of the first dimension in output is the same as size(mat,dim).
% * If dim is an array, then the first output dimension corresponds to the input dimensions
%   concatenated in the order specified.
%
% The second output allows to reverse the trasnformation using ant.mat.unsquash.
%
% Example:
%
%   x = rand( 1,4,5,1,7,1,3 );
%   compare = @(a,b) all(a(:) == b(:));
%
%   [y1,r1] = ant.mat.squash(x); compare(x,ant.mat.unsquash(y1,r1))
%   [y2,r2] = ant.mat.squash(x,3); compare(x,ant.mat.unsquash(y2,r2))
%   [y3,r3] = ant.mat.squash(x,[5,2]); compare(x,ant.mat.unsquash(y3,r3))
%
% See also: ant.mat.unsquash
%
% JH

    nd = ndims(mat);

    if nargin < 2, dim = ant.nsdim(mat); end
    assert( isnumeric(dim), 'Second input should be numeric.' );
    assert( all( dim>0 & dim<=ndims(mat) ), 'Bad dimension(s).' );
    
    % information for forward transformation
    insize = size(mat);
    other = setdiff(1:nd,dim);
    perm = [ dim, other ];
    nr = prod(insize(dim));
    nc = prod(insize(other));
    
    % save information for reverse transformation
    rev.nd      = nd;
    rev.insize  = size(mat);
    rev.outsize = [nr,nc];
    rev.tmpsize = insize(perm);
    rev.perm    = perm;
    rev.dim     = dim;
    
    % do transformation
    mat = reshape( permute(mat,perm), [nr,nc] );
    
end
