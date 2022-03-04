function val = reject( varargin )
%
% val = dk.reject( condition, fmt, varargin )
% val = dk.reject( channel, condition, fmt, varargin )
%
% Default channel is 'error'.
% Returns true if the rejection passes, false otherwise.
%
% JH

    validE = {'e', 'err', 'error'};
    validW = {'w', 'warn', 'warning'};
    validI = {'i', 'info'};
    validD = {'d', 'dbg','debug'};

    arg1 = varargin{1};
    if ischar(arg1) && ismember(lower(arg1),[validE validW validI validD])
        chan = lower(arg1);
        cond = varargin{2};
        args = varargin(3:end);
    else
        chan = 'err';
        cond = arg1;
        args = varargin(2:end);
    end

    val = ~any(logical(cond));
    if ~val
        switch chan
            case validE
                s.message = sprintf(args{:});
                s.stack   = dbstack(1);
                error(s);
            case validW
                dk.warn( args{:} );
            case validI
                dk.info( args{:} );
            case validD
                dk.debug( args{:} );
            otherwise
                error('[dk.reject] That should never happen.');
        end
    end
    
end
