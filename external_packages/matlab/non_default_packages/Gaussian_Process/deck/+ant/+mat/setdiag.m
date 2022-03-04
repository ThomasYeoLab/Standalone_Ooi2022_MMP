function M = setdiag( M, val )
%
% M = ant.mat.setdiag( M, val )
%
% Set diagonal elements to specified value(s).
%   M does not need to be square
%   val can be a vector, in which case it needs to match the number of rows
%
% JH
    
    assert( ndims(M) <= 3, 'Unexpected dimensions.' );

    [r,c,s] = size(M);
    d = 1:(r+1):(r*c);
    
    for i = 1:s
        M( d + (i-1)*r*c ) = val;
    end

end
