function debug( varargin )
    dk.logger.default().write( 'd', 1, varargin{:} );
end