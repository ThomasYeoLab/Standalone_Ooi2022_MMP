function [m,dev] = ft_firwsord( wtype, fs, df, dev )
%
% Copied from FieldTrip.
% firwsord() - Estimate windowed sinc FIR filter order depending on
%              window type and requested transition band width
%
% Usage:
%   >> [m, dev] = firwsord(wtype, fs, df);
%   >> m = firwsord('kaiser', fs, df, dev);
%
% Inputs:
%   wtype - char array window type. 'rectangular', 'bartlett', 'hann',
%           'hamming', 'blackman', or 'kaiser'
%   fs    - scalar sampling frequency
%   df    - scalar requested transition band width
%   dev   - scalar maximum passband deviation/ripple (Kaiser window
%           only)
%
% Output:
%   m     - scalar estimated filter order
%   dev   - scalar maximum passband deviation/ripple
%
% References:
%   [1] Smith, S. W. (1999). The scientist and engineer's guide to
%       digital signal processing (2nd ed.). San Diego, CA: California
%       Technical Publishing.
%   [2] Proakis, J. G., & Manolakis, D. G. (1996). Digital Signal
%       Processing: Principles, Algorithms, and Applications (3rd ed.).
%       Englewood Cliffs, NJ: Prentice-Hall
%   [3] Ifeachor E. C., & Jervis B. W. (1993). Digital Signal
%       Processing: A Practical Approach. Wokingham, UK: Addison-Wesley
%
% Copyright (C) 2005-2014 Andreas Widmann, University of Leipzig, widmann@uni-leipzig.de

    winTypeArray = {'rectangular', 'bartlett', 'hann', 'hamming', 'blackman', 'kaiser'};
    winDfArray   = [0.9, 2.9, 3.1, 3.3, 5.5];
    winDevArray  = [0.089, 0.056, 0.0063, 0.0022, 0.0002];

    % Check arguments
    if nargin < 3 || isempty(fs) || isempty(df) || isempty(wtype)
        error('Not enough input arguments.')
    end

    % Window type
    wtype = find(strcmpi(wtype, winTypeArray));
    if isempty(wtype)
        error('Unknown window type.')
    end

    df = df / fs; % Normalize transition band width

    if wtype == 6 % Kaiser window
        if nargin < 4 || isempty(dev)
            error('Not enough input arguments.')
        end
        devdb = -20 * log10(dev);
        m = 1 + (devdb - 8) / (2.285 * 2 * pi * df);
    else
        m = winDfArray(wtype) / df;
        dev = winDevArray(wtype);
    end

    m = ceil(m / 2) * 2; % Make filter order even (FIR type I)

end
