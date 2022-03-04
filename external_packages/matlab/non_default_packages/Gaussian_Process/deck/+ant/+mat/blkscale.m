function A = blkscale( A, scale, blk )
%
% A = ant.mat.blkscale( A, scale, blk )
%
% Scale specified blocks in matrix A.
% 
% + Single-block call:
%   blk is a vector or matrix of indices, and scale is a scalar.
%   if blk is a vector, then the on-diagonal block A(blk,blk) is scaled.
%   if blk is a matrix, then the block A(blk(1,:),blk(2,:)) is scaled.
%   
% + Multi-block call:
%   blk is a cell of indices, and scale is a vector of same length, 
%    or if it is a scalar, the same scale is applied to all blocks.
%
% JH

    % make sure blk is a cell
    if isnumeric(blk), blk = {blk}; end
    assert( ismatrix(A) && iscell(blk) && isnumeric(scale), 'Bad input types.' );
    
    % replicate scales for each block
    n = numel(blk);
    if (n > 1) && isscalar(scale)
        scale = scale * ones(1,n);
    end
    assert( numel(blk) == numel(scale), 'Size mismatch between blocks and scales.' );
    
    % scale blocks
    for i = 1:n
        [r,c] = get_block_indices( blk{i} );
        s = scale(i);
        A(r,c) = s * A(r,c); 
    end

end

function [r,c] = get_block_indices( blk )

    if isvector(blk)
        r = blk(:);
        c = r';
    else
        assert( ismatrix(blk) && any(size(blk) == 2), 'blk should be 2xn' );
        if size(blk,1) ~= 2 && size(blk,2) == 2, blk = blk'; end
        r = blk(1,:)';
        c = blk(2,:);
    end

end
