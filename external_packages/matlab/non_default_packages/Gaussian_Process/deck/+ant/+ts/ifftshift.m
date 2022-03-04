function x = ifftshift(x,dim)
%
% x = ifftshift(x,dim)
%
% Inverse of ant.ts.fftshift.
%
% JH

    if nargin < 2, dim = ant.nsdim(x); end
    
    n = size(x,dim);
    n = floor( n/2 + 1 );
    x = circshift( x, n, dim );

end
