function [ph,fh] = sdplot( x, y, yd, varargin )
%
% [ph,fh] = dk.ui.sdplot( x, y, yd, theme )
% [ph,fh] = dk.ui.sdplot( x, y, yd, popt, fopt )
%
% Mean-deviation plot.
% Plot the curve (x,y) on top of a background area spanning (y-yd,y+yd).
%
% Required: x, y, yd (same size vectors)
% Optional: popts, fopts (forwarded to plot and fill, respectively)
%
% Options can be:
%   cell of key/value options
%   1x3 vec (interpreted as color)
%   struct (option names as fields)
%
% yd can also be nx2 or 2xn, to specify the lower/upper bounds of the area.
%
% Example:
%   x  = linspace( 0, 2*pi, 100 ); 
%   y  = sin(x); 
%   yd = .05 + abs(y)/10; 
%   dk.ui.sdplot(x,y,yd);
%
% JH

    [popt,fopt,fcol] = dk.priv.linefill_options(varargin{:});
    
    % dimensions and formatting
    n = numel(x);
    assert( numel(y)==n, 'y size mismatch.' );
    x = x(:); 
    y = y(:);
    
    % prepare plot
    if numel(yd) == 2*n
        
        % case with upper and lower bounds specified manually
        assert( ismatrix(yd) && any(size(yd)==2), 'yd should be 2xn or nx2.' );
        if size(yd,1)==2, yd = yd'; end % make it nx2
        
    else
        
        % case with std specified 
        yd = yd(:);
        assert( numel(yd)==n, 'yd size mismatch.' );
        assert( all(yd >= 0), 'Deviations should be positive.' );
        yd = [y-yd,y+yd];
    end
    
    % plot it
    fh = fill( [x; flipud(x)], [yd(:,1); flipud(yd(:,2))], fcol, fopt{:} ); hold on;
    ph = plot( x, y, popt{:} ); hold off;

end
