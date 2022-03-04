function debug( fmt, varargin )
if dk.verb.get(true) >= dk.verb.get('debug')
    dk.println( ['[dk.D] ' fmt], varargin{:} );
    dbstack(1);
end
end