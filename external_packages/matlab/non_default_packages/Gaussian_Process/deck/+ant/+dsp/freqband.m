function [lo,hi] = freqband( ts, prc )
%
% [lo,hi] = ant.dsp.freqband( ts, prc=[1,99] )
% 
% Shorthand for finding frequency band.
% This is essentially:
%   ant.dsp.FourierTransform(ts).power_band();
%
% JH

    if nargin < 2, prc=[1,99]; end
    p = prc / 100;
    [lo,hi] = ant.dsp.FourierTransform(ts).power_band( p(1), p(2) );

end
