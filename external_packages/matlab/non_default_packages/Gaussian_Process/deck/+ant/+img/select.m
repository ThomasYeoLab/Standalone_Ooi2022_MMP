function h = select( data, img, callback, scale, varargin )
%
% ant.img.select( data, img, callback, scale=[1,1], varargin )
%
% Show image into a figure, and allow selecting points within that image, finding the
% closest corresponding datapoint.
%
% Inputs data and img must be struct{x,y,z}, where x and y can be vectors or matrices.
%
% Scale is applied to the x and y axes (eg to display ms instead of sec).
% Additional inputs are forwarded to ant.img.show
%
% A selection entry is added to the menu bar, and each selection invokes the callback as:
%   callback( kx, ky, kz )
%
% where the data point closest to the selection is: data.x(kx) data.y(ky) data.z(kz)
% 
% JH

    % check scale
    if nargin < 4 || isempty(scale), scale = 1; end
    if isscalar(scale), scale = scale*[1,1]; end

    % force x and y to be vectors
    data = check_meshgrid(data);
    img  = check_meshgrid(img);

    % show image
    h = ant.img.show( { scale(1)*img.x, scale(2)*img.y, img.z }, varargin{:} );

    % setup selection
    function selection(x,y,varargin)
        
        % find closest match
        kx = ant.math.closest( x/scale(1), data.x );
        ky = ant.math.closest( y/scale(2), data.y );
        kz = sub2ind( size(data.z), kx, ky );
        
        callback( kx, ky, kz );
    end
    dk.widget.menu_ginput( @selection );

end

function grid = check_meshgrid( grid )

    if ~isvector(grid.x), grid.x = grid.x(1,:); end
    if ~isvector(grid.y), grid.y = grid.y(:,1); end

end
