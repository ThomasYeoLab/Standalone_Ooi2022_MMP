function log( chan, varargin )
    dk.logger.default().write( chan, 1, varargin{:} );
end