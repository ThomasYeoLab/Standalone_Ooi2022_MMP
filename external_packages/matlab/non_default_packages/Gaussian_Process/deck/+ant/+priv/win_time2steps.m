function varargout = win_time2steps( ts_in, varargin )
%
% [wsize,wstep,wburn] = ant.priv.win_time2steps( ts_in, varargin )
% window = ant.priv.win_time2steps( ts_in, varargin ) % 1x3 output
%
% Convert window parameters (length,step,burn) in any format accepted 
% by ant.priv.win_parse from SECONDS to NUMBER OF STEPS.
%
% The first and last timepoint in each window are then:
%  first = (1+wburn) : wstep : (Ntimes - (wsize-1))
%   last = first + wsize-1;
%
% NOTE: we assume that input time-series is arithmetically sampled.
%
% JH

    % parse window config
    [len,step,burn] = ant.priv.win_parse(varargin{:});
    
    % convert to number of steps
    wsize = ts_in.numsteps( len )+1; % # of timepoints in window is 1+windowLength
    wstep = ts_in.numsteps( step );
    wburn = ts_in.numsteps( burn );
    
    assert( ts_in.nt >= wburn+wsize, 'Bad window config.' );
    if nargout == 1
        varargout = {[wsize,wstep,wburn]};
    else
        varargout = {wsize,wstep,wburn};
    end
    
end
