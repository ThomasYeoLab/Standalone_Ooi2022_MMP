function print( fmt, varargin )
%
% dk.print( fmt, varargin )
%
% Formatted display, equivalent to:
%   fprintf( [fmt '\n'], varargin{:} );
%
% JH

    fprintf( [fmt '\n'], varargin{:} );
end
