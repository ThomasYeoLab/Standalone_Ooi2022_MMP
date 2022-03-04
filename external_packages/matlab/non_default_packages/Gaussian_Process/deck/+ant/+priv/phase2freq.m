function frq = phase2freq(phi,fs)
%
% frq = ant.priv.phase2freq(phi,fs)
%
% Compute instantaneous frequency from instantaneous phase in a numerically stable manner.
%
% JH

    if nargin < 2, fs=1; end

    x = cos(phi);
    y = sin(phi);

    frq = x .* ant.ts.diff( y, fs ) - y .* ant.ts.diff( x, fs );
    frq = max( frq, 0 ) / (2*pi);
    
end