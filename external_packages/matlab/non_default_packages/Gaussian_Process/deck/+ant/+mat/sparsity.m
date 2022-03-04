function s = sparsity( M, thresh )
%
% Return the sparsity of input matrix M between 0 (full) and 1 (0).
% The sparsity is evaluated relatively to the number of elements with magnitude < thresh.
% The default threshold is 1e-6.

    if nargin < 2, thresh = eps; end
    
    s = sum(abs(M(:)) < thresh) / numel(M);

end
