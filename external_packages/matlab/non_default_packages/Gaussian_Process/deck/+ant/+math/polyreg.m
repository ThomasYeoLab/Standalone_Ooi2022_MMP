function [coef,rsq] = polyreg( x, y, n, doplot )
%
% [coef,rsq] = ant.math.polyreg( x, y, n, doplot )
%
% Fits polynomial of degree n to input data.
% Returns n+1 coefficients sorted from the highest power down. 
% Second output is the adjusted r-squared.
% If no output is assigned, the fit is plotted.
%
% JH

    if nargin < 3 || isempty(n), n = 1; end
    
    % format data suitably
    [x,o] = sort(x(:));
    y = dk.tocol(y(o));
    
    % run polyfit estimation
    coef = polyfit( x, y, n );
    
    % compute adjusted r-squared
    rsq = y - polyval(coef,x);
    rsq = 1 - sum(rsq.^2) / var(y) / (length(y)-length(coef)+1);
    
    % plot results
    if nargin < 4, doplot = nargout == 0; end
    if doplot
        
        scatter( x, y, 'bo' ); hold on;
        t = linspace(x(1),x(end),300);
        plot( t, polyval( coef, t ), 'r-', 'LineWidth', 3 ); hold off;
        title(sprintf( 'Polynomial regression (degree %d, r^2= %g)', n, rsq ));
        legend( 'Original data', 'Regression' );
        
    end
    
end
