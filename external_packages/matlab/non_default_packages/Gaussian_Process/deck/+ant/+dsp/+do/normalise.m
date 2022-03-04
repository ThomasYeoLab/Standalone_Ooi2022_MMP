function ts_out = normalise( ts_in, method, preserve_mean )
%
% ts_out = normalise( ts_in, method, preserve_mean=false )
%
% Normalise input time-courses, either independently of each other or maintainting relative amplitudes.
% Note that signals are ALWAYS DEMEANED before normalisation, hence the second input preserve_mean if 
% you want the output to have the same average as the input.
%
% METHODS:
%
%     mean  Demean only.
%      std  Equivalent to zscore.
%   maxstd  Divide by the largest std across signals.
%      rms  Divide by the RMS norm of each signal (same as L2-norm / sqrt(Ndim))
%   maxrms  Divide by the largest RMS norm across signals.
%
% JH
    
    if nargin < 3, preserve_mean=false; end

    ts_out = ts_in.demean();
    switch lower(method)
        
        case 'mean'
            % nothing to do
        
        case 'std'
            ts_out.vals = dk.bsx.rdiv( ts_out.vals, max(eps,ts_out.sdev) );
            
        case 'maxstd'
            ts_out.vals = ts_out.vals / max([eps,ts_out.sdev]);
            
        case 'rms'
            ts_out.vals = dk.bsx.rdiv( ts_out.vals, max(eps,ts_out.rms) );
            
        case 'maxrms'
            ts_out.vals = ts_out.vals / max([eps,ts_out.rms]);
            
        otherwise
            error( 'Unknown method "%s".', method );
        
    end
    
    if preserve_mean
        ts_out.vals = dk.bsx.add( ts_out.vals, ts_in.mean );
    end

end