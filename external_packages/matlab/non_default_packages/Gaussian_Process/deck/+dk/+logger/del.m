function del(name)
%
% dk.logger.del(name)
%
% Delete existing Logger with specified name.
%
% See also: dk.logger.Logger
%
% JH

    delete( dk.logger.get(name).close() );
end