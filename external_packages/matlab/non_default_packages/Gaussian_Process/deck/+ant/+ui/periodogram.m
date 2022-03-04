function den = periodogram( ts, method, varargin )
%
% den = ant.ui.periodogram( ts, method, varargin )
%
% Compute Fourier spectral density using specified method, and plot the result.
% The method defaults to 'pwelch' if the input signal has more than 2000 timepoints.
% Additional arguments are forwarded to ant.dsp.FourierSpectrum.plot
%
% See also: ant.dsp.FourierSpectrum
%
% JH

    if nargin < 2 || isempty(method)
        if ts.nt > 2000
            method = 'welch';
        else
            method = 'fourier';
        end
    end

    den = ant.dsp.FourierSpectrum(ts,method);
    arg = [{'parent',gca},varargin];
    den.plot(arg{:});

end
