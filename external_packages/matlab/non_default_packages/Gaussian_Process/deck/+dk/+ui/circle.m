function h = circle( C, R, varargin )
%
% h = dk.ui.circle( centre, radius=1, varargin )
%
% Draw a circle with specified centre and radius.
% Additional arguments are forwarded to rectangle, and the output is a graphical handle.
%
% There are 4 properties:
%   - EdgeColor
%   - FaceColor
%   - LineWidth
%   - LineStyle
%
% JH

    if nargin < 1 || isempty(C), C=[0,0]; end
    if nargin < 2 || isempty(R), R=1; end

    h = rectangle( 'Position', [C-R,2*R,2*R], 'Curvature', [1,1], varargin{:} );

end