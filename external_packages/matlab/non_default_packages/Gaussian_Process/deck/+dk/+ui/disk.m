function h = disk( C, R, npts, col, varargin )
%
% h = dk.ui.disk( centre=[0 0], radius=1, npts=42, col='k', varargin )
%
% Draw a disk (filled circle) with specified radius, at the centre provided.
% Additional arguments are forwarded to patch, and the output is a handle to the patch.
%
% JH

    if nargin < 1 || isempty(C), C=[0 0]; end
    if nargin < 2 || isempty(R), R=1; end
    if nargin < 3 || isempty(npts), npts=42; end
    if nargin < 4 || isempty(col), col='k'; end
    
    t = linspace( 0, 2*pi, npts );
    h = fill( C(1)+R*cos(t), C(2)+R*sin(t), col, varargin{:} );

end