function [y, ty] = downsample( x, tx, fs, win )
%
% [y,ty] = ant.ts.downsample( x, tx, fs, win=hamming )
%
% Downsample a time-series using moving average.
%
% JH
    
    if nargin < 4, win = 'hamming'; end
    
    [x,tx] = dk.formatmv(x,tx,'vertical');
    
    % make sure input is sampled arithmetically
    [ari,dt] = ant.priv.is_arithmetic(tx,1e-3);
    if ~ari
        dk.info('[ant.ts.downsample] Input is not regular, fallback to Matlab implementation.');
        [y,ty] = ant.ts.resample( x, tx, fs );
        return;
    end
    
    % check that fs is greater than current sampling rate
    newdt = 1/fs;
    if abs(newdt-dt)/newdt < 1e-6
        y=x; ty=tx; 
        return; 
    end
    assert( newdt > dt, 'Requested sampling rate is higher than current one, use ant.ts.upsample instead.' );
    
    % save last timepoint
    tlast = tx(end);
    xlast = x(end,:);
    
    % frequency discrepancy caused by integer step matching
    target_fs = fs;
    actual_fs = 1 / ( dt * ceil(newdt/dt) );
    
    % if too large, upsample to a suitable rate before downsampling
    if dk.num.msdeq(actual_fs,target_fs) < 2 % the two MSD must be equal
        dk.debug('[ant.ts.downsample] Upsampling before downsampling to correct for frequency discrepancy.');
        newdt  = newdt / ceil(newdt/dt);
        [x,tx] = ant.ts.upsample( x, tx, 1/newdt, 'linear' );
    end
    
    % compute sliding parameters
    wstep = ceil( 1/dt/fs );
    wsize = ceil( wstep / 0.6 );
    nwin  = dk.num.nextint( (size(x,1) - wsize)/wstep );
    
    % prepare window
    wy = ant.ts.window( win, wsize );
    wy = wy(:)' / sum(wy);
    
    % sliding average
    b = 1 + (0:nwin-1)*wstep;
    e = b + wsize-1;
    t = [tx(1); (tx(b) + tx(e))/2; tlast];
    y = [x(1,:); ant.mex.sliding_dot( x, wy, wstep ); xlast];
    
    % interpolate to final precision
    ty = transpose( tx(1) : (1/fs) : tx(end) );
    y  = interp1( t, y, ty, 'pchip' );
    
end
