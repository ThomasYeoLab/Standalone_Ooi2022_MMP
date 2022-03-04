function [p,pi] = randperm( N )
%
% Random permutation and its inverse.

    p = randperm( N );
    
    if nargout > 1
        pi(p) = 1:N;
    end

end
