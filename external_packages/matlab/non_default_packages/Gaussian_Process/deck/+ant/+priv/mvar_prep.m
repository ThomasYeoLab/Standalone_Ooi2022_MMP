function [ts,m,fs] = mvar_prep( ts, cut, fac )
%
% [ts,m,fs] = mvar_prep( ts, cut=0.99, fac=20 )
%
% Demean and downsample to a frequency consistent with power distribution if needed.
% Currently, the time-series is resampled if:
%   ts.fs > fac*minfreq(cumpow >= 0.99)
%
% JH
    
    if nargin < 3, fac=20; end
    if nargin < 2, cut=0.99; end

    m = ts.mean();
    T = ant.dsp.FourierTransform(ts);
    maxfs = ceil(fac * max(T.power_cut(cut)));
    
    fs = ts.fs;
    if fs > maxfs
        ts = ts.resample(maxfs);
        fs = maxfs;
    end
    
end
