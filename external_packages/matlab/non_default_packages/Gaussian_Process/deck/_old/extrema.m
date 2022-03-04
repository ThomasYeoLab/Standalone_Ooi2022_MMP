function [lmin,lmax] = extrema( x, inc_endpoints, strict )
%
% [lmin,lmax] = ant.ts.extrema( data, inc_endpoints=false, strict=false )
%
% This function is a fast local extrema finder (returns indices).
% In the case of plateau in the data, the function returns the index of the _first_ point.
% If nargout == 0, a figure is opened, displaying the extrema.
%
% Example:
%
%   data = [25 8 15 5 5 10 10 10 3 1 20 7];
%   ant.ts.extrema(data);
%
% JH

    if nargin < 2, inc_endpoints = false; end
    if nargin < 3, strict = false; end
    assert( isvector(x) && isnumeric(x), 'Input data should be a numeric vector.' );
    if strict
        comp = @(x) x < 0;
    else
        comp = @(x) x <= 0;
    end
    
    dx = diff(x(:),1,1);
    
    if inc_endpoints
        zc = [comp(dx(1:end-1) .* dx(2:end)); 1];
        le = [ -dx(1); zc .* dx ];
    else
        zc = [comp(dx(1:end-1) .* dx(2:end)); 0];
        le = [ 0; zc .* dx ];
    end
    
    lmin = find( le < 0 );
    lmax = find( le > 0 );
    
    if nargout == 0 
        
        figure(); n = numel(x);
        
        plot( 1:n, x ); hold on;
        plot( lmin, x(lmin), 'bo' );
        plot( lmax, x(lmax), 'ro' ); hold off;
        
        title('Showing local extrema');
        L = {'Data'};
        if ~isempty(lmin), L{end+1}='Local min'; end
        if ~isempty(lmax), L{end+1}='Local max'; end
        legend(L{:});
        
    end
    
end
