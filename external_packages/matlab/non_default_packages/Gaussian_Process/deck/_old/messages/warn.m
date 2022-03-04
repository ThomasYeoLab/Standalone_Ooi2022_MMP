function warn( fmt, varargin )
if dk.verb.get(true) >= dk.verb.get('warning')
    warning( ['[dk.W] ' fmt], varargin{:});
end
end
