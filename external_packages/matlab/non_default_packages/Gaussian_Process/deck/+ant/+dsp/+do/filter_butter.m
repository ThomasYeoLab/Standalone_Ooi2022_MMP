function ts_out = filter_butter( type, ts_in, freq, varargin )
%
% ts_out = filter_butter( type, ts_in, freq, varargin )
%
% Filter input timecourse using Butterworth filter.
% Input type should be one of: lp (low), hp (high), bp (bandpass), bs (bandstop)
%
%
% OPTIONS
% -------
%
%     tol  Safety margin at the border of (0,1) for relative frequencies.
%          This is to prevent numerical instabilities (default: 1e-2).
%   order  Initial order of the filter (default: 15).
%          If instability is detected, the filter will be recursively split into
%          sequential filters of lower degrees.
%
%
% See also: ant.priv.filter_split
% 
% JH

    opt = dk.obj.kwArgs(varargin{:});
    
    % frequency information
    fs = ts_in.fs; % sampling rate
    fn = fs/2; % Nyquist frequency
    
    % options
    tol   = opt.get('tol',   1e-2 ); % safety margin at the border of (0,1) for relative frequencies
    order = opt.get('order', 15 );   % filter order
    freq  = dk.num.clamp( freq/fn, [tol,1-tol] ); % make sure it is in (0,1)
    
    function f = get_filter(ord)
        assert( ord >= 2, 'Order is too low.' ); f.o = ord;
        switch lower(type)
            case 'lp', [f.b,f.a] = butter( ord, freq, 'low' );
            case 'hp', [f.b,f.a] = butter( ord, freq, 'high' );
            case 'bp', [f.b,f.a] = butter( ord, freq, 'bandpass' );
            case 'bs', [f.b,f.a] = butter( ord, freq, 'stop' );
        end
    end

    % split the filter into a sequence of smaller order ones as long as unstable poles exist
    f  = ant.priv.filter_split( @get_filter, order );
    nf = numel(f);
    v  = ts_in.vals;
    
    % apply the filters sequentially
    for i = 1:nf
        fi = f(i);
        v  = filtfilt( fi.b, fi.a, v );
    end
    
    % create output time-series
    ts_out = ant.TimeSeries( ts_in.time, v );

end
