function [wtimes,wframes] = win_times( ts_in, varargin )
    
    % if input is a time vector, make it a time-series (that's a bit hacky)
    if isnumeric(ts_in) && isvector(ts_in)
        ts_in = ant.TimeSeries( ts_in, ts_in );
    end
    
    % configure sliding window
    swin = ant.dsp.SlidingWindow( ts_in, varargin{:} );
    
    % compute time for each window
    wframes = swin.frame( 1:swin.nwin );
    wtimes  = mean( ts_in.time(wframes), 2 );

end
