function [i,j] = symunpair( z )
%
% [i,j] = ant.math.symunpair( z )
% ij = ant.math.symunpair( z )
%
% Inverse of ant.math.sympair, with the constraint i >= j.
%
% JH

    i = 1 + sqrt(1 + 8*z);
    i = ceil(i/2) - 1;
    j = z - i.*(i-1)/2;
    
    if nargout == 1
        i = [i(:),j(:)];
    end
    
end
