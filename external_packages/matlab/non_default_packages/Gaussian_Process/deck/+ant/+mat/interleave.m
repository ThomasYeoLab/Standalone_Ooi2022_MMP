function out = interleave( arrays, block )
%
% out = ant.mat.interleave( arrays, block_size=1 )
%
% Interleave input arrays.
%
% Example:
% 
% ant.mat.interleave( {1:6, 7:12} )
%      1     7     2     8     3     9     4    10     5    11     6    12
% 
% ant.mat.interleave( {1:6, 7:12}, 2 )
%      1     2     7     8     3     4     9    10     5     6    11    12
% 
% ant.mat.interleave( {1:6, 7:12}, 3 )
%      1     2     3     7     8     9     4     5     6    10    11    12
% 
% ant.mat.interleave( {1:6, 7:12}, 6 )
%      1     2     3     4     5     6     7     8     9    10    11    12
%
% JH

    if nargin < 2, block=1; end
    m = cellfun( @numel, arrays );
    
    assert( iscell(arrays), 'First input must be a cell of arrays.' );
    assert( all(diff(m)==0), 'There must be at least two inputs, and all inputs must have the same number of elements.' );
    assert( mod(m(1),block) == 0, 'Array size must be a multiple of block size.' );
    
    n = numel( arrays ); % number of arrays
    m = m(1); % number of elements per array
    b = block; % block size
    t = n*m; % size of ouput array
    s = n*b; % section size in output array
    k = bsxfun( @plus, 1:s:t, (0:b-1)' ); % indices of target elements in output array
    k = k(:);
    
    out = zeros(n*m,1);
    for i = 1:n
        out((i-1)*b+k) = arrays{i}(:);
    end
    
end
