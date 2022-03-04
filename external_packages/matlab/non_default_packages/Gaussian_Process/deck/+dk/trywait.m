function varargout = trywait( ntry, twait, fhandle, msg )
%
% varargout = dk.trywait( ntry, twait, fhandle, msg='Failed attempt.' )
% 
% Try to run function handle at most ntry times, and wait twait seconds in case of error.
%
% A message (msg) can be provided to be displayed in case of failure.
% If msg is a function handle, it is called with the exception: msg(err) -> string
%
% The error message is displayed as a warning at each failed trial.
% After ntry attempts have failed, an error is thrown.
% 
% JH

    if nargin < 4, msg = 'Failed attempt.'; end

    while ntry > 0
        
        ntry = ntry - 1;
        try
            if nargout > 0
                [varargout{:}] = fhandle();
            else
                fhandle();
            end
            ntry = 0;

        catch err

            assert( ntry > 0, 'Too many failed attempts, aborting.' );
            if dk.is.fhandle(msg)
                dk.warn( '%s', msg(err) );
            else
                dk.warn( '%s', msg );
            end

            dk.print( 'Waiting %d second(s) to retry (%d attempt(s) left).', twait, ntry );
            pause(twait);
        end
        
    end
    
end
