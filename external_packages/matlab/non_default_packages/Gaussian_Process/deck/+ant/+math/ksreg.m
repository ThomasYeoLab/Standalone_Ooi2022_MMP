function r = ksreg( x, y, n, b, kerf, doplot )
%
% r = ant.math.ksreg( x, y, n=100, b=(optimal), kerf=rat2, doplot=(nargout==0) )
%
% Kernel Smoothing Regression.
%
% INPUTS:
%
%        x  Coordinates (not necessarily in order)
%        y  Associated (scalar) values
%        n  Number of desired output points (default: 100)
%        b  Kernel bandwidth for regression (default: optimal bandwidth from litterature)
%     kerf  Kernel function (default: second-order rational)
%   doplot  Plot results in current figure (default: true if no output)
%
% KERNEL FUNCTIONS:
%
%     exp1  @(t) exp( -abs(t) )
%     exp2  @(t) exp( -t.*t )
%     rat1  @(t) 1./(1+abs(t))
%     rat2  @(t) 1./(1+t.*t)
%
% OUTPUT:
%
%   Structure with fields {x,y,s} where x is a vector of linearly smapled coordinates 
%   in the input range, y the vector of associated values, and s the vector of associated 
%   pointwise weighted std.
% 
%
% Inspired by:
% http://uk.mathworks.com/matlabcentral/fileexchange/19195-kernel-smoothing-regression
%
% JH

    % sort input data
    [x,o] = sort(x(:));
    y = dk.tocol(y(o));
    
    % set a sensible number of points in output
    if nargin < 3 || isempty(n), n = 100; end
    
    % optimal bandwidth suggested by Bowman and Azzalini (1997) p.31
    r.n = numel(x);
    r.a = (4/3/r.n)^0.2 / 0.6745;
    if nargin < 4 || isempty(b)
        hx = median(abs(x-median(x)));
        hy = median(abs(y-median(y)));
        b  = r.a * sqrt( hy * hx );
    end
    r.b = b;
    
    % regression kernel
    if nargin < 5 || isempty(kerf), kerf = 'rat2'; end
    if ischar(kerf)
    switch lower(kerf)
        
        case 'exp1'
            kerf = @(t) exp( -abs(t) );
        case 'exp2'
            kerf = @(t) exp( -t.*t );
        case 'rat1'
            kerf = @(t) 1./(1+abs(t));
        case 'rat2'
            kerf = @(t) 1./(1+t.*t);
        
    end
    end
    
    % check inputs
    assert( isscalar(n) && n > 0, 'n should be positive scalar.' );
    assert( isscalar(b) && b > sqrt(eps)*n, 'b should be a positive scalar, there might not be enough variation in the data.' );
    assert( kerf(1) == kerf(-1), 'ker should be a scalar symmetric function.' );

    r.x = linspace(x(1),x(end),n);
    r.y = zeros(1,n);
    r.s = zeros(1,n);
    r.w = zeros(1,n);
    for i = 1:n
        w = kerf( (x - r.x(i))/b );
        r.w(i) = sum(w);
        r.s(i) = ant.stat.wstd( y, w );
        r.y(i) = sum(w.*y) / sum(w);
    end

    % plot
    if nargin < 6, doplot = nargout == 0; end
    if doplot
        
        scatter( x, y, 'bo' ); hold on;
        plot( r.x, r.y, 'r-', 'LineWidth', 3 ); hold off;
        title(sprintf( 'Kernel smoothing regression (bw = %g)', b ));
        legend( 'Original data', 'Regression' );
        
    end

end
