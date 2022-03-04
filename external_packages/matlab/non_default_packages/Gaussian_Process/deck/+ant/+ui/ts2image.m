function [img,xvals,yvals] = ts2image( ts, mag, nrows, ncols, vrange, trange )
%
% [img,xvals,yvals] = ant.ui.ts2image( ts, mag, nrows, ncols, vrange, trange )
%
% Turns the input time-series TS into a NROWS x NCOLS image where the rows
% correspond to the range of values taken by all signals in ts, and the
% columns correspond to time.
%
% Essentially, each signal in ts leaves a "trace" into the output image;
% that is, every timepoint of every signal corresponds to a pixel in the
% output image. If the ranges (VRANGE: value range, TRANGE: time range)
% are set manually, timepoints that fall outside of these ranges will be
% discarded (and therefore will not appear in the output image). By default
% the time-range is the full timeframe, and the value-range is set to the
% extrema across all signals and timepoints.
%
% The input MAG is used to decide how to accumulate timepoints that map
% to the same pixel in the output image. If it is left empty, it is set 
% to 1 by default. If it is a scalar, it is repeated into a matrix as 
% large as ts.vals. Otherwise it is expected to be a matrix as large as 
% ts.vals, such that to each timepoint corresponds a magnitude, and any
% given pixel in the output image then contains the sum of the magnitudes
% of the timepoints that map to it.
%
% JH

    if nargin < 6
        trange = ts.time([1,end]); 
    end
    if nargin < 5
        [vmin,vmax] = ant.stat.extrema( ts.vals(:) );
        vrange      = [vmin,vmax];
    end
    if isempty(mag), mag = 1; end

    xvals = linspace( trange(1), trange(2), ncols );
    yvals = linspace( vrange(1), vrange(2), nrows );
    
    if isscalar(mag)
        mag = mag * ones(size(ts.vals));
    end
    
    dx = diff(trange)/(ncols-1);
    dy = diff(vrange)/(nrows-1);
    ns = size(ts.vals,2);
    
    x  = 1+round( (ts.time - trange(1)) / dx );
    y  = 1+round( (ts.vals - vrange(1)) / dy );
    z  = repmat( x, 1, ns );
    
    xm = x >= 1 & x <= ncols;
    ym = y >= 1 & y <= nrows;
    ym = bsxfun( @and, ym, xm );
    
    img = accumarray( [y(ym), z(ym)], mag(ym), [nrows,ncols] );
    
end
