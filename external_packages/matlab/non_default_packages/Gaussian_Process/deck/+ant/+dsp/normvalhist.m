function [count,edge] = normvalhist( ts, nbins, nstd )
%
% [count,edge] = ant.dsp.normvalhist( ts, nbins=50, nstd=<auto> )
%
% Compute histogram of normalised values for input time-series.
% The automatic span is determined from the 99th percentile of normalised data.
%
% Output counts are BxN where B are the bins, corresponding to the edges.
%
% JH

    if nargin < 2, nbins=50; end
    
    count = ts.normalise().vals;
    if nargin < 3
        nstd = ceil(prctile( abs(count(:)), 99 ));
    end
    
    edge = nstd * linspace(-1,1,nbins+1);
    count = histc( count, edge );

end