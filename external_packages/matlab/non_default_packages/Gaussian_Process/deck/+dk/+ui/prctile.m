function [ph,fh] = prctile( x, y, lo, hi, varargin )
%
% [ph,fh] = dk.ui.prctile( x, y, lo, hi, theme ) 
% [ph,fh] = dk.ui.prctile( x, y, lo, hi, popts, fopts )
%
% Percentile plot.
% Vector x are the abcissa locations.
% Matrix y should be n x numel(x).
% lo and hi should be integers between 0 and 100.
% 
% This will plot the median of y across rows in blue, on top of an area in red 
% bounded at the top by the "hi" percentile of y across rows, and at the bottom
% by the "lo" percentile of y across rows.
%
% Required: x, y, lo, hi
% Optional: popts, fopts (cell)
%
% Example:
%   x  = linspace( 0, 2*pi, 100 ); 
%   y  = bsxfun( @plus, sin(x), randn(42,100) ); 
%   dk.ui.prctile(x,y,23,66);
%
% JH

    [popt,fopt,fcol] = dk.priv.linefill_options(varargin{:});
    
    [y,x] = dk.formatmv(y,x,'vert');
    assert( isscalar(lo) && isscalar(hi), 'Lower/higher percentiles should integers between 0 and 100.' );
    
    n = size(y,2);
    y_md = median(y,2);
    
    if n >= 3
        y_lo = prctile( y, lo, 2 );
        y_hi = prctile( y, hi, 2 );
        fh = fill( vertcat(x,flipud(x)), vertcat(y_hi,flipud(y_lo)), fcol, fopt{:} ); hold on;
    end
    ph = plot( x, y_md, popt{:} ); hold off;

end
