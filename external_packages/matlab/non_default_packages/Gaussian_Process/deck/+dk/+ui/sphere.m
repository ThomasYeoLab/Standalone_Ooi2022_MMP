function h = sphere( C, R, npts, col, varargin )
%
% h = dk.ui.sphere( centre=[0,0,0], radius=1, npts=42, col='k', varargin )
%
% Draw a sphere (surface) with specified radius, at the centre provided.
% Additional arguments are forwarded to surf, and the output is a handle to the surf.
%
% Color is set as "FaceColor", and "EdgeColor" is set to none.
%
% JH

    if nargin < 1 || isempty(C), C=[0 0 0]; end
    if nargin < 2 || isempty(R), R=1; end
    if nargin < 3 || isempty(npts), npts=42; end
    if nargin < 4 || isempty(col), col='k'; end
    
    if isscalar(R), R = R*[1,1,1]; end
    [x,y,z] = sphere(npts);
    
    x = C(1) + R(1)*x;
    y = C(2) + R(2)*y;
    z = C(3) + R(3)*z;
    
    h = surf( x, y, z, 'FaceColor', col, 'EdgeColor', 'none', varargin{:} );

end