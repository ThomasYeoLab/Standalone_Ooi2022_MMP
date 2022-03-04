function ts_out = resample( ts_in, varargin )
%
% ts_out = resample( ts_in, Name/Value )
%
%   Resample input time-series. 
%
%
% OPTIONS
% -------
%
%   fs      Specify the new sampling frequency.
%   dt      Specify the new time-step.
%   npts    Specify the desired number of points in output.
%   win     Window used for downsampling (default: 'hamming', cf ant.ts.window)
%
%
% NOTE
% ----
%
% The resampling behaviour is different for down-sampling and up-sampling:
%
%   - For down-sampling, the time-series is first up-sampled to a time-step divisble by the 
%     target time-step, and then a moving average is applied to reduce to the desired number 
%     of time-points using the specified window.
%
%   - For up-sampling, we use ant.ts.upsample, which uses Matlab's interp1 with method 'pchip'.
%
%
% See also: ant.ts.downsample, ant.ts.upsample
%
% JH

    args = dk.obj.kwArgs(varargin{:});
    win  = args.get('win','hamming');
    
    % current timestep
    cur_dt = ts.dt(true);

    % target frequency
    if args.has('fs')
        
        fs = args.get('fs');
        tgt_dt = 1/fs;
        
    % target number of points
    elseif args.has('npts')
        
        npts = args.get('npts');
        tgt_dt = ts_in.tspan / (npts+1);
        
    % target timestep
    else
        tgt_dt = args.get('dt');
    end
    
    if abs(tgt_dt - cur_dt) < eps
        time = ts_in.time;
        vals = ts_in.vals;
    elseif tgt_dt > cur_dt 
        [vals,time] = ant.ts.downsample( ts_in.vals, ts_in.time, 1/tgt_dt, win );
    else
        [vals,time] = ant.ts.upsample( ts_in.vals, ts_in.time, 1/tgt_dt );
    end
    
    if nargout == 0
        ts_in.assign( time, vals );
    else
        ts_out = ant.TimeSeries(time,vals); 
    end
    
end
