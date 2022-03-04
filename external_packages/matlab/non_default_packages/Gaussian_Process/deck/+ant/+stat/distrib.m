function d = distrib(x,n,s)
%
% d = ant.stat.distrib(x,n,s)
%
% Compute the value distribution on data x.
% x is the data, considered internally as a single vector x(:).
% n is the number of points for the density estimation (default 101).
% s is the number of standard deviations to consider (default 5).
%
% Output d is a struct with fields
%   x   Standardised values at which the distribution was estimated
%   y   Corresponding distribution estimates
%   m   Sample mean
%   s   Sample std
%   w   Sample skewness
%   k   Sample kurtosis
%
% JH

    if nargin < 3, s = 5; end
    if nargin < 2, n = 101; end
    
    n = floor(n);
    if dk.is.even(n), n = n+1; end
    
    assert( n > 11, 'Number of points (2nd input) too low. Set to > 11.' );
    assert( s >= 2, 'Number of standard deviations (3rd input) too low. Set to >= 2.' );
    
    x = x(:);
    d.m = mean(x);
    d.s = std(x);
    d.w = skewness(x);
    d.k = kurtosis(x);
    
    [d.y,d.x] = ksdensity( (x-d.m)/max(d.s,eps), linspace(-s,s,n) );
    
    if nargout == 0
        plot( d.x, d.y );
        xlabel(sprintf('Standard deviations (s=%g)',d.s));
        ylabel('Density estimate');
    end

end
