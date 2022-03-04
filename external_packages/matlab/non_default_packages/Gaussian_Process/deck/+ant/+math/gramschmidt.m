function [og,on] = gramschmidt(M)
% [og,on] = gramschmidt( M )
%
% Gram-Schmidt orthogonalization of matrix M.
%
% Input:
%   M is a matrix.
%
% Constraints:
%   M is square with full rank.
%
% Output:
%   og is the orthogonalization
%   on is the orthonormalization
    
    n = size(M,1);
    assert( ismatrix(M) && all(size(M)==n) && rank(M)==n, ...
        'M should be a square matrix with full rank.' );
    
    % Allocate & initialize
    og = M; 
    on = zeros(size(M));
    on(:,1) = og(:,1)/ant.math.lnorm(og(:,1),2,1);
    
    % Ortho(gon/norm)alize
    for k = 2:n        
        v = M(:,k);
        u = og(:,1:(k-1));
        u = v - ant.math.bsxdot( u, ant.math.bsxdot(u,v) ./ sum(u.*u), 2);
        
        og(:,k) = u;
        on(:,k) = u/ant.math.lnorm(u);
    end

end
