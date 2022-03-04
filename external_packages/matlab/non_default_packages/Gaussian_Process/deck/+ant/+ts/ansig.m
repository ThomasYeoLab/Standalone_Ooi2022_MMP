function varargout = ansig( x, fs )
%
% [env,phi,frq] = ant.ts.ansig( x, fs=1 )
%
% Decomposed analytic signal from input data.
% 
% INPUTS:
%
%     x    Ntimes x Nsignals matrix, sampled arithmetically in time (equally-spaced points).
%    fs    Input sampling frequency, used for estimating instantaneous frequency (default: 1Hz).
% 
% OUTPUTS:
%
%   env    Oscillatory envelopes for each signal.
%          NOTE: the envelope is NOT re-meaned.
%   phi    Instantaneous phase for each signal.
%   frq    Instantaneous frequency for each signal 
%          Computed only if required, in cycles/unit unless fs is defined.
%
% If no output is collected, a new figure is opened, showing the trajectory of the analytic
% signal in the complex plane (only works for single-channel TCs).
%
%
% See also: hilbert, ant.ts.envelope
%
% JH
    
    if nargin < 2, fs=1; end

    if isreal(x)
        % compute analytic transform on real inputs
        switch ant.priv.meth_ansig()
            case 'base'
                [sig,env] = antran_base(x); 
            case 'pad'
                [sig,env] = antran_pad(x); 
            case 'interp'
                [sig,env] = antran_interp(x);
            otherwise
                error( '[bug] Unknown ansig method.' );
        end
    else
        sig = x; % otherwise, assume analytic signal is given
        env = abs(sig);
    end
    
    switch nargout
        case 0
            assert( isvector(sig), 'Only scalar time-courses allowed for plotting.' );
            figure;
                [x,y] = pol2cart( angle(sig), env );
                plot( x, y, 'k-' );
                title('Complex analytic signal');
                axis equal; grid on;
            
        case 3
            % estimate frequency only if required
            phi = angle(sig);
            frq = ant.priv.phase2freq( phi, fs );
            varargout = { env, phi, frq };
            
        otherwise
            % compute envelope and phase
            varargout = { env, angle(sig) };
    end

end

% basic Hilbert transform
function [sig,env] = antran_base(x)

    sig = hilbert(dk.bsx.sub( x, mean(x,1) ));
    env = abs(sig);

end

% Hilbert transform with nfft
function [sig,env] = antran_pad(x)

    nt = nextpow2(size(x,1));
    sig = hilbert(dk.bsx.sub( x, mean(x,1) ), 2^nt);
    env = abs(sig);

end

% analytic transform with extrema-based envelope
function [sig,env] = antran_interp(x)

    [lo,up] = ant.ts.envelope(x);
    x = x - (lo+up)/2;
    
    env = (up-lo)/2;
    sig = hilbert( x ./ max(eps,env) );
    
end
