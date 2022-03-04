function beta = ft_kaiserbeta(dev)
%
% Copied from FieldTrip.
% kaiserbeta() - Estimate Kaiser window beta
%
% Usage:
%   >> beta = pop_kaiserbeta(dev);
%
% Inputs:
%   dev       - scalar maximum passband deviation/ripple
%
% Output:
%   beta      - scalar Kaiser window beta
%
% References:
%   [1] Proakis, J. G., & Manolakis, D. G. (1996). Digital Signal
%       Processing: Principles, Algorithms, and Applications (3rd ed.).
%       Englewood Cliffs, NJ: Prentice-Hall
%
% Copyright (C) 2005-2014 Andreas Widmann, University of Leipzig, widmann@uni-leipzig.de

    devdb = -20 * log10(dev);

    if devdb > 50
        beta = 0.1102 * (devdb - 8.7);
    elseif devdb >= 21
        beta = 0.5842 * (devdb - 21)^0.4 + 0.07886 * (devdb - 21);
    else
        beta = 0;
    end

end
