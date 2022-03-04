function info( fmt, varargin )
if dk.verb.get(true) >= dk.verb.get('info')
    dk.println( ['[dk.I] ' fmt], varargin{:} );
end
end
