function [M,blocks] = blkdiag( n, blocks )
% 
% M = ant.mat.blkdiag( n, blocks )
%
% Create a nxn logical block-diagonal matrix.
%
% If blocks is SCALAR, it specifies the number of blocks; the size of each
% block may vary by one unit to fit the integer size of the matrix.
%
% If blocks is a VECTOR, then each element specifies the relative size-weight
% of the corresponding block, and the number of blocks is length(blocks).
%

    assert( n > 1, 'n <= 1.' );
    assert( all(blocks > 0), 'Bad blocks value.' );
        
    if numel(blocks) == 1
        nb     = ceil(blocks);
        blocks = ones(1,nb);
    else
        nb     = numel(blocks);
        blocks = blocks(:)';
    end
    
    
    % Reduce the size of the blocks proportionally to their weight 
    % until we reach the right matrix size
    blocks = ceil( n * blocks/sum(blocks) );
    while sum(blocks) > n
        [~,k] = max(blocks);
        blocks(k) = blocks(k)-1;
    end
    assert( all(blocks), 'Unfeasible.' );
    
    
    % Create the output matrix
    M = false(n);
    c = 1;
    for b = 1:nb
        
        block_start = c;
        block_end   = c + blocks(b)-1;
        block       = block_start : block_end;
        
        M(block,block) = true;
        c = block_end + 1;
        
    end
    
end
