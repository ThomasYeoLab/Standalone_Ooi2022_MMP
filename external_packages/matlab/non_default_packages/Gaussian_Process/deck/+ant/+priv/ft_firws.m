function [b, a] = ft_firws(m, f, t, w)
%
% Copied from FieldTrip.
% firws() - Designs windowed sinc type I linear phase FIR filter
%
% Usage:
%   >> b = firws(m, f);
%   >> b = firws(m, f, w);
%   >> b = firws(m, f, t);
%   >> b = firws(m, f, t, w);
%
% Inputs:
%   m - filter order (mandatory even)
%   f - vector or scalar of cutoff frequency/ies (-6 dB;
%       pi rad / sample)
%
% Optional inputs:
%   w - vector of length m + 1 defining window {default blackman}
%   t - 'high' for highpass, 'stop' for bandstop filter {default low-/
%       bandpass}
%
% Output:
%   b, a - filter coefficients
%
% Example:
%   fs = 500; cutoff = 0.5; df = 1;
%   m  = firwsord('hamming', fs, df);
%   [b,a] = firws(m, cutoff / (fs / 2), 'high', window('hamming', m + 1)); 
%
% References:
%   Smith, S. W. (1999). The scientist and engineer's guide to digital
%   signal processing (2nd ed.). San Diego, CA: California Technical
%   Publishing.
%
% Copyright (C) 2005 Andreas Widmann, University of Leipzig, widmann@uni-leipzig.de

    a = 1;

    if nargin < 2
        error('Not enough input arguments');
    end
    if length(m) > 1 || ~isnumeric(m) || ~isreal(m) || mod(m, 2) ~= 0 || m < 2
        error('Filter order must be a real, even, positive integer.');
    end
    f = f / 2;
    if any(f <= 0) || any(f >= 0.5)
        error('Frequencies must fall in range between 0 and 1.');
    end
    if nargin < 3 || isempty(t)
        t = '';
    end
    if nargin < 4 || isempty(w)
        if ~isempty(t) && ~ischar(t)
            w = t;
            t = '';
        else
            w = ant.priv.ft_window( 'blackman', m+1 );
        end
    end
    
    w = w(:)'; % Make window row vector
    b = fkernel(m, f(1), w);

    if length(f) == 1 && strcmpi(t, 'high')
        b = fspecinv(b);
    end

    if length(f) == 2
        b = b + fspecinv(fkernel(m, f(2), w));
        if isempty(t) || ~strcmpi(t, 'stop')
            b = fspecinv(b);
        end
    end
    
    
    % Compute filter kernel
    function b = fkernel(m, f, w)
        m = -m / 2 : m / 2;
        b(m == 0) = 2 * pi * f; % No division by zero
        b(m ~= 0) = sin(2 * pi * f * m(m ~= 0)) ./ m(m ~= 0); % Sinc
        b = b .* w; % Window
        b = b / sum(b); % Normalization to unity gain at DC
    end

    % Spectral inversion
    function b = fspecinv(b)
        b = -b;
        b(1, (length(b) - 1) / 2 + 1) = b(1, (length(b) - 1) / 2 + 1) + 1;
    end
    
end
