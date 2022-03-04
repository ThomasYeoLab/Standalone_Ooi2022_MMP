function ts_out = slidingavg( ts_in, len, step, burn )
%
% ts_out = ant.dsp.slidingavg( ts_in, len, step, burn )
%
% Downsample the input timeseries using a moving average (with Tukey window).
% Window parameters should be in SECONDS.
%
% JH

    if nargin < 4, burn=0; end
    if nargin < 3, step=len/3; end

    [wsize,wstep,wburn] = ant.priv.win_time2steps( ts_in, [len,step,burn] );
    
    win_time = ones( wsize, 1 );
    win_vals = tukeywin( wsize, 0.25 );
    
    ts_out = ant.TimeSeries( ...
        ant.mex.sliding_avg( ts_in.time, win_time, wstep, wburn ), ...
        ant.mex.sliding_avg( ts_in.vals, win_vals, wstep, wburn )  ...
    );

end
