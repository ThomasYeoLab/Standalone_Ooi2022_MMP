function avg = sliding_avg( signals, weights, wstep, wburn )
%
% avg = ant.mex.sliding_avg( signals, weights, wstep, wburn )
%
% Fast weighted average on a sliding window.
%
% INPUTS:
%
%   signals  Ntime x Nsignals real matrix
%
%   weights  Wlength x 1 vector of weights
%            If scalar, it is interpreted as the length of a square window.
%            Weights should be non-negative, and they are normalised internally to sum to 1.
%
%     wstep  Step of the window, in number of timepoints.
%            DEFAULT: length(weights)/3
%
%     wburn  Number of timepoints to ignore at the start.
%            DEFAULT: 0
%
% JH
    
    % check weights
    if isscalar(weights)
        weights = ones( weights, 1 );
    else
        weights = weights(:);
    end
    
    assert( ismatrix(signals) && isreal(signals), 'Input signal should be a real matrix.' );
    assert( all(weights >= 0), 'Weights should be positive.' );
    assert( sum(weights) > eps, 'Sum of weights is too small.' );
    
    if nargin < 4, wburn = 0; end
    if nargin < 3, wstep = fix(numel(weights)/3); end
    
    % normalise weights
    weights = weights / sum(weights);
    avg = ant.mex.sliding_dot( signals, weights, wstep, wburn );
    
end
