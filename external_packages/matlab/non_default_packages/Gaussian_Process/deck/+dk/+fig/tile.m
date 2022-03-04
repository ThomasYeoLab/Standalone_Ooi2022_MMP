function tile( gsize, figures, screen )
% 
% dk.fig.tile( gsize, figures, screen )
%
% Move and resize a group of figures given in input according to a specified grid size [nrows, ncols].
% figures should be a cell of figure handles, or a vector of figure numbers.
%
% If screen is not specified, the tile is done on the screen that contains most of the figures listed.
% 
% JH

    assert( nargin >= 2, 'Not enough inputs.' );
    
    % figure numbers given as an input array
    if isnumeric(figures)
        figures = dk.mapfun( @(k) figure(k), figures, false );
    end
    
    % array of figures given in input, make it a cell
    if ~iscell(figures)
        figures = dk.mapfun( @(x) x, figures, false );
    end

    % dimensions of the grid
    nrows  = gsize(1);
    ncols  = gsize(2);
    ncells = nrows * ncols;
    nfigs  = numel(figures);
    
    assert( nrows > 0 && ncols > 0, 'Bad grid size.' );
    assert( nfigs <= ncells, 'Too many figures to tile.' );
    
    % normalised left-bottom positions for all figures
    [left,bottom] = ndgrid( linspace(0,1,ncols+1), linspace(0,1,nrows+1) );
    left   = left(1:end-1,1:end-1);
    bottom = fliplr(bottom(1:end-1,1:end-1));
    width  = 1/ncols;
    height = 1/nrows;

    % find out where most of the figures are
    if nargin < 3
        screen = zeros( 1, nfigs );
        for i = 1:nfigs
            [~,~,screen(i)] = dk.fig.position(figures{i});
        end
        screen = mode(screen);
    end
    spos = get( 0, 'MonitorPositions' );
    spos = spos( screen, : );
    
    % convert normalised positions to pixel positions
    bottom = bottom * spos(4) + spos(2)-1;
    height = height * spos(4);
    left   = left   * spos(3) + spos(1)-1;
    width  = width  * spos(3);
    
    % apply positions
    for i = 1:nfigs
        set( figures{i}, ...
            'units', 'pixels', ...
            'outerposition', [left(i) bottom(i) width height], ...
            'units', get(figures{i},'units') ...
        );
    end
    
end
