function [df,maxDf] = ft_fir_df( cutoffArray, Fs )
%
% Copied from FieldTrip.
%
% FIR_DF computes default and maximum possible transition band width from
% FIR filter cutoff frequency(ies)
%
% Use as
%   [df, maxDf] = fir_df(cutoffArray, Fs)
% where
%   cutoffArray filter cutoff frequency(ies)
%   Fs          sampling frequency in Hz
%
% Required filter order/transition band width is estimated with the
% following heuristic: transition band width is 25% of the lower cutoff
% frequency, but not lower than 2 Hz, where possible (for bandpass,
% highpass, and bandstop) and distance from passband edge to critical
% frequency (DC, Nyquist) otherwise. 
%
% Copyright (c) 2014, Andreas Widmann

    if nargin < 2 || isempty(cutoffArray) || isempty(Fs)
        error('Not enough input arguments.')
    end

    % Constants
    TRANSWIDTHRATIO = 0.25;
    Fn = Fs / 2;

    % Max possible transition band width
    cutoffArray = sort(cutoffArray);
    maxTBWArray = [cutoffArray * 2 (Fn - cutoffArray) * 2 diff(cutoffArray)];
    maxDf       = min(maxTBWArray);

    % Default filter order heuristic
    df = min([max([cutoffArray(1) * TRANSWIDTHRATIO 2]) maxDf]);

end
