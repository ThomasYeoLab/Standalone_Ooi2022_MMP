function x = wjet( n, f )
%
% x = dk.cmap.wjet( n=128, f=0 )
%
% Weighted jet colormap based on Matlab jet function.
% n controls the number of colors, and f the brightness at the centre of the color range.
% f should be between 0 (no downweighting) and 1 (centre is black).
%
% JH

    if nargin < 1, n=128; end
    if nargin < 2, f=0; end
    
    x = jet(n);
    w = (1:n)/n - 0.5;
    w = exp( - 45 * w(:).^2 );
    x = bsxfun( @power, x, 1-0.7*w );
    x = bsxfun( @times, x, 1-f*w );
    
    if nargout == 0, dk.cmap.show(x); end
    
end