function success = assert( chan, cdt, varargin )
%
% success = dk.assert( condition, fmt, varargin )
% success = dk.assert( channel, condition, fmt, varargin )
%
% Default channel is 'error'.
% Returns true if the assertion passes, false otherwise.
%
% Available channels are:
%   e,err,error
%   w,warn,warning
%   i,info
%   d,dbg,debug
%
% JH

    assert( nargin >= 2, 'At least two inputs required.' );
    log = dk.logger.default();
    try
        lvl = log.match_level(chan);
        lvl = lvl(1);
        msg = sprintf(varargin{:});
    catch
        lvl = 'e';
        msg = sprintf(cdt,varargin{:});
        cdt = chan;
    end

    success = all(logical(cdt));
    if ~success
        log.write(lvl, log.stdepth+1, msg);
    end
    
end
