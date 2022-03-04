function [liA,locB] = func_ismember( A, B )

    if ~iscell(A), A = {A}; end
    if ~iscell(B), B = {B}; end
    
    A = cellfun( @func2str, A, 'UniformOutput', false );
    B = cellfun( @func2str, B, 'UniformOutput', false );
    
    [liA,locB] = ismember( A, B );

end
