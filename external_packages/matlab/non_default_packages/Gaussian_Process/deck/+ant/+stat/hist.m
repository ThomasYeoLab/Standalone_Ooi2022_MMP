function d = hist(x,n,s)
%
% d = ant.stat.hist(x,n,s)
%
% Compute the value histogram on data x.
% x is the data, considered internally as a single vector x(:).
% n is the number of bins (default 31).
% s is the number of standard deviations to consider (default 5).
%
% Output d is a struct with fields
%   b   Bin edges for standardised values
%   n   Number of elements in input x
%   x   Bin centres
%   y   Histogram counts 
%   m   Sample mean
%   s   Sample std
%   w   Sample skewness
%   k   Sample kurtosis
%
% NOTE:
%   Depending on how many standard deviations are specified (input s), and how 
%   many outliers there are (see kurtosis), it is possible that d.n ~= sum(d.y).
%
% JH

    if nargin < 3, s = 5; end
    if nargin < 2, n = 31; end
    
    n = floor(n);
    m = floor(sqrt(numel(x)));
    assert( m >= 11, 'There are too few points in x to compute a useful histogram.' );
    
    if m < n
        warning( 'Too few points in x for desired %d bins, setting to %d instead.', n, m );
        n = m;
    end
    if dk.is.even(n), n = n+1; end
    
    assert( n >= 11, 'Number of bins (2nd input) too low. Set to > 11.' );
    assert( s >= 2, 'Number of standard deviations (3rd input) too low. Set to >= 2.' );
    
    x = x(:);
    d.n = numel(x);
    d.m = mean(x);
    d.s = std(x);
    d.w = skewness(x);
    d.k = kurtosis(x);
    
    b = linspace(-s,s,n+1);
    d.b = b;
    d.y = histcounts( (x-d.m)/max(d.s,eps), b );
    d.x = b(1:end-1) + diff(b)/2;
    
    if nargout == 0
        bar( d.x, d.y, 1 );
        xlabel(sprintf('Standard deviations (s=%g)',d.s));
        ylabel('Histogram');
    end

end
