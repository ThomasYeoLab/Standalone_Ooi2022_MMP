function m = freqmode( ts )
%
% m = ant.dsp.freqmode( ts )
% 
% Shorthand for finding frequency modes.
% This is just:
%   ant.dsp.FourierTransform(ts).frequency_modes();
%
% JH

    m = ant.dsp.FourierTransform(ts).frequency_modes();

end
