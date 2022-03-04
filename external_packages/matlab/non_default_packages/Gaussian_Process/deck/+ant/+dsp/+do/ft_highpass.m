function ts_out = ft_highpass( ts_in, fcut, varargin )
%
% Adapted from FieldTrip.

    opt = dk.obj.kwArgs(varargin{:});
    
    nt = ts_in.nt; % number of time-points
    fs = ts_in.fs; % sampling frequency
    fn = fs/2;     % Nyquist frequency
    
    type = opt.get('type','butter');
    switch type
        
        case {'but','butter'}
            
            order = opt.get('order',6);
            hfilt = @(ord) butter( ord, fcut/fn, 'high' );
            
        case 'fir'
            
            order = min( 3*fix(fs/fcut), floor((nt-1)/3) );
            if rem(order,2) == 1, order = order-1; end
            order = opt.get('order',order);
            hfilt = @(ord) fir1( ord, fcut/fn, 'high' );
            
        case 'brickwall'
            
            n = 2^nextpow2(nt);
            f = (0:n-1)*fs;
            f = abs(f(:)-fn) >= fcut;
            s = fftshift(fft( ts_in.vals, n ));
            s = ifftshift(bsxfun( @times, s, f ));
            s = real(ifft(s));
            
            ts_out = ant.TimeSeries( ts_in.time, s(1:nt,:) );
            return;
            
        case 'firws'
            
            [df,maxdf]  = ant.priv.ft_fir_df(fcut,fs);
            df          = min( opt.get('df',df), maxdf );
            dev         = opt.get('dev',1e-3);
            win         = opt.get('window','hamming');
            [order,dev] = ant.priv.ft_firwsord( win, fs, df, dev );
            
            switch win
                case 'kaiser'
                    win = ant.priv.ft_window( win, order+1, ant.priv.ft_kaiserbeta(dev) );
                otherwise
                    win = ant.priv.ft_window( win, order+1 );
            end
            hfilt = @(ord) ant.priv.ft_firws( ord, fcut/fn, 'high', win );
            
        otherwise
            error('[ant.dsp.ft_highpass] Unsupported filter type "%s".',type);
    end
    
    ts_out = ant.TimeSeries( ts_in.time, ...
        ant.priv.ft_filter( ts_in.vals, hfilt, order, opt.get('instability_fix','default') ) ...
    );
    
end
