function z = sympair( i, j )
%
% z = ant.math.sympair( i, j )
%
% Symmetric pairing function; map pairs of input indices to unique integer.
% Reference: https://math.stackexchange.com/a/1125559/51744
% 
% JH

    z = min(i,j);
    i = max(i,j);
    z = z + i.*(i-1)/2;
    
end
