function h = errbarh( x, y, varargin )
%
% h = dk.ui.errbarh( x, y, Xlength, Yheight=[], varargin )
%
% Draw horizontal error bars.
%
% See also: dk.ui.errbar
%
% JH

    h = dk.ui.errbar( y, x, varargin{:} );

end