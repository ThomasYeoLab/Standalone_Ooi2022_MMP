function warn( varargin )
    dk.logger.default().write( 'w', 1, varargin{:} );
end