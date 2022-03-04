function h = area( x, y, col, varargin )
% 
% h = dk.ui.area( x, y, col, varargin )
%
% Plot curve y(x) with colored area under it.
% Works regardless of the sign of y (zero-crossings are fine too).
%
% x and y must be vector with the same number of elements.
% col must be a valid RGB triplet (1x3 vector).
% options can be passed by key/value pairs, or as a struct.
% 
% JH

    % check inputs
    x = x(:);
    y = y(:);
    
    assert( numel(x) == numel(y), 'Input size mismatch.' );
    assert( isvector(col) && numel(col)==3, 'Invalid color vector.' );

    % parse options
    opt.EdgeColor = col;
    opt = dk.struct.merge( opt, dk.c2s(varargin{:}) );
    opt = dk.struct.to_cell( opt );
    
    % draw the figure
    x = [x(1); x; x(end); x(1)];
    y = [0; y; 0;0];
    h = fill( x, y, col, opt{:} );
    
end
