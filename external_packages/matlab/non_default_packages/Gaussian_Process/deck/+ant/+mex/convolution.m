function res = convolution( signals, window, wstep, wburn )
%
% res = ant.mex.convolution( signals, window, wstep, wburn=0 )
%
% Fast 1D convolution.
%
% INPUTS:
%
%   signals  Ntime x Nsignals real matrix
%    window  Wlength x 1 convlution window
%
%     wstep  Step of the window, in number of timepoints.
%            DEFAULT: length(weights)/3
%
%     wburn  Number of timepoints to ignore at the start.
%            DEFAULT: 0
%
% JH

    if nargin < 3, wstep = fix(numel(window)/3); end
    if nargin < 4, wburn = 0; end
    
    assert( ismatrix(signals) && isreal(signals), 'Input signal should be a real matrix.' );
    res = ant.mex.sliding_dot( signals, flipud(window(:)), wstep, wburn );
    
end
