function w = ft_window( t, m, a )
%
% Adapted from FieldTrip.
% windows() - Symmetric window functions
%
% Usage:
%   >> h = windows(t, m);
%   >> h = windows(t, m, a);
%
% Inputs:
%   t - char array 'rectangular', 'bartlett', 'hann', 'hamming',
%       'blackman', 'blackmanharris', 'kaiser', or 'tukey'
%   m - scalar window length
%
% Optional inputs:
%   a - scalar or vector with window parameter(s)
%
% Output:
%   w - column vector window
%
% Copyright (C) 2014 Andreas Widmann, University of Leipzig, widmann@uni-leipzig.de

    % size param
    m = round(m);
    assert( m >= 1, 'Invalid window length.' );
    if m == 1, w=1; return; end

    % even/odd length
    odd_len = mod(m, 2);
    if odd_len
        x = (0:(m - 1) / 2)' / (m - 1);
    else
        x = (0:m / 2 - 1)' / (m - 1);
    end

    switch lower(t)
        case 'rectangular'
            w = ones(length(x), 1);
        case 'bartlett'
            w = 2 * x;
        case 'hann'
            a = 0.5;
            w = a - (1 - a) * cos(2 * pi * x);
        case 'hamming'
            a = 0.54;
            w = a - (1 - a) * cos(2 * pi * x);
        case 'blackman'
            a = [0.42 0.5 0.08 0];
            w = a(1) - a(2) * cos (2 * pi * x) + a(3) * cos(4 * pi * x) - a(4) * cos(6 * pi * x);
        case 'blackmanharris'
            a = [0.35875 0.48829 0.14128 0.01168];
            w = a(1) - a(2) * cos (2 * pi * x) + a(3) * cos(4 * pi * x) - a(4) * cos(6 * pi * x);
        case 'kaiser'
            if nargin < 3 || isempty(a)
                a = 0.5;
            end
            w = besseli(0, a * sqrt(1 - (2 * x - 1).^2)) / besseli(0, a);
        case 'tukey'
            if nargin < 3 || isempty(a)
                a = 0.5;
            end
            if a <= 0 % Rectangular
                w = ones(length(x), 1);
            elseif a >= 1 % Hann
                w = 0.5 - (1 - 0.5) * cos(2 * pi * x);
            else
                mTaper = floor((m - 1) * a / 2) + 1;
                xTaper = 2 * (0:mTaper - 1)' / (a * (m - 1)) - 1;
                w = [0.5 * (1 + cos(pi * xTaper)); ones(length(x) - mTaper, 1)];
            end
        otherwise
            error('Unkown window type "%s".',t);
    end

    % Make symmetric
    if odd_len
        w = [w; w(end - 1:-1:1)];
    else
        w = [w; w(end:-1:1)];
    end
    
end
