function x = fftshift(x,dim)
%
% x = ant.ts.fftshift(x,dim=ns)
%
% Matlab's fftshift puts the Nyquist frequency as the lowest negative frequency.
% For consistency with the real-input one-sided output, we implement our own shift, in which
% the Nyquist frequency is kept as the last positive frequency.
%
% JH

    if nargin < 2, dim = ant.nsdim(x); end

    n = size(x,dim);
    n = floor( (n-1)/2 );
    x = circshift( x, n, dim );

end
