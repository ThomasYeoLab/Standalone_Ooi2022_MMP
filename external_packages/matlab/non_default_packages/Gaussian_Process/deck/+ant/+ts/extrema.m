function [lmin,lmax] = extrema( x, t )
%
% [lmin,lmax] = ant.ts.extrema( x, thresh=0 )
%
% Quick local extrema finder.
% Returns indices of local minima/maxima separately.
%
% The algorithm first attempts to find extrema in the interior of x,
% i.e. with first and last point excluded. If no extremum is found, 
% then the index of the min or max value across the entire signal is
% returned instead; e.g. for a constant signal, lmin=lmax=1.
%
% Differences smaller than input threshold are ignored.
%
% JH

    if nargin < 2, t=0; end
    assert( isvector(x), 'This function only accepts single-schannel time-courses as vectors.' );

    % exclude first and last point
    dx = diff(x(:));
    zc = dx(1:end-1) .* dx(2:end) <= 0; % zero-crossing
    le = zc .* dx(1:end-1); % backward-derivative at zero-crossing
    
    lmin = 1+find( le < -t );
    lmax = 1+find( le >  t );
    
    % prevent empty outputs
    if isempty(lmin), [~,lmin] = min(x); end
    if isempty(lmax), [~,lmax] = max(x); end
    
    % show result for debug
    if nargout == 0
        
        plot( x, 'k-', 'LineWidth', 2 ); hold on;
        plot( lmin, x(lmin), 'b^' ); 
        plot( lmax, x(lmax), 'rv' ); hold off
        
    end

end
