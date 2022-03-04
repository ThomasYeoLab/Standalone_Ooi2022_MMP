function [data,time,frame] = slidingfun( fun, ts, varargin )
%
% [data,time,frame] = ant.dsp.slidingfun( fun, ts, varargin )
%
% Apply function to a sliding window over input time-series.
% The signature of the callback function should be:
%       fun( ts, kfirst, klast )
%
% where kfirst, klast are respectively the first and last indices 
% of the current window.
%
% The output of the callback can be anything, as long as it's a 
% single output. 
%
% OUTPUT:
%
%    data  1xW cell array with callback results for each window.
%    time  Wx1 vector with the time at the center of each window.
%   frame  Wx2 array with kfirst and klast for each window.
% 
% JH

    [len,step,burn] = ant.priv.win_parse( varargin{:} );
    
    % sliding window given in seconds, and converted internally to timesteps
    window = ant.dsp.SlidingWindow( ts, [len,step,burn], true );

    % allocate output
    nw    = window.nwin;
    data  = cell(1,nw);
    time  = zeros(nw,1);
    frame = zeros(nw,2);

    % iterate on each window
    while window.valid()
        wi = window.index;
        [b,e] = window.frame;
        
        data{ wi } = fun( ts, b, e );
        time( wi ) = (ts.time(b)+ts.time(e))/2;
        frame( wi, : ) = [b,e];
        
        window.slide_forward();
    end

end
