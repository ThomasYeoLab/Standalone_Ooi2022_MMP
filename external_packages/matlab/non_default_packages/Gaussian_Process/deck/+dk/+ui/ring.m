function h = ring( C, R, npts, col, varargin )
%
% h = dk.ui.ring( centre=[0 0], radii=[0.8 1], npts=42, col='k', varargin )
%
% Draw a ring with specified inner and outer radii, at the centre provided.
% Additional arguments are forwarded to patch, and the output is a handle to the patch.
%
% JH

    if nargin < 1 || isempty(C), C=[0 0]; end
    if nargin < 2 || isempty(R), R=[0.8 1]; end
    if nargin < 3 || isempty(npts), npts=42; end
    if nargin < 4 || isempty(col), col='k'; end

    Rin = R(1);
    Rout = R(2);
    
    t = linspace( 0, 2*pi, npts );
    u = fliplr(t);
    
    x = [ Rout, Rin*cos(t), Rout*cos(u) ];
    y = [ 0, Rin*sin(t), Rout*sin(u) ];
    
    h = fill( C(1)+x, C(2)+y, col, varargin{:} );

end