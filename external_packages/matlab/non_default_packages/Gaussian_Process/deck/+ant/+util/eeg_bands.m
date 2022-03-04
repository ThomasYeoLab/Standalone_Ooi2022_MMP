function b = eeg_bands( varargin )
%
% b = ant.util.eeg_bands()
%   Return structure with frequency-bands relevant to M/EEG analysis.
%
%
% b = ant.util.eeg_bands(name)
%   Return specified frequency-band (1x2 vector).
%
%
% b = ant.util.eeg_bands(name1, name2, ...)
%   Return cell-array with requested bands.
%
% JH

    % Definitons based on:
    %
    % Electric Fields of the Brain: The Neurophysics of EEG (2nd Ed, 2006)
    % Paul L. Nunez, Ramesh Srinivasan
    % 
    b.delta = [ 1,  4];
    b.theta = [ 4,  8];
    b.alpha = [ 8, 13];
    b.beta  = [13, 30];
    b.gamma = [30, 70];
    
    % defined for convenience
    b.rest       = [ 1,  30]; % d+t+a+b
    b.low_alpha  = [ 8,  10];
    b.high_alpha = [10,  13];
    b.low_beta   = [13,  20];
    b.high_beta  = [20,  30];
    b.high_gamma = [70, 110];
    
    % Limited output
    if nargin > 0
        
        % either pass band-names as a cell-array of strings, or as individual inputs
        names = dk.wrap(varargin);
        
        % select the required bands
        b = dk.mapfun( @(x) b.(lower(x)), names, false );
        
        % if there is only one requested band, don't return a cell
        if numel(b)==1, b=b{1}; end
        
    end
    
end
