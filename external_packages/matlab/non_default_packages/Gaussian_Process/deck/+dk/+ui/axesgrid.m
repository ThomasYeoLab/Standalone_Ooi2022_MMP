function ax = axesgrid( nrows, ncols, varargin )
%
% dk.ui.axesgrid( nrows, ncols, varargin )
%
% Create a grid of axes with specified spacing (similar to the grid of plotmatrix).
% Returns a matrix of Axes objects.
%
% OPTIONS: all dimensions are in normalised units
%
%      xpad  Total padding between figures in the width  direction (default: 0.05).
%      ypad  Total padding between figures in the height direction (default: 0.05).
%   xmargin  Total left+right margin (default: 0.13).
%   ymargin  Total top+bottom margin (default: 0.15).
%    figure  Create grid in specified figure (one is created otherwise).
% 
% JH

    assert( nrows>0 && ncols>0, 'Number of rows and columns must be non-zero.' );

    % parse options
    opt = dk.obj.kwArgs(varargin{:});
        xpad = opt.get( 'xpad', 0.05 );
        ypad = opt.get( 'ypad', 0.05 );
        xmar = opt.get( 'xmargin', 0.13 );
        ymar = opt.get( 'ymargin', 0.15 );
        fig  = opt.get( 'figure', nan );

    % create figure if needed
    if ishandle(fig)
        figure(fig); clf;
    else
        fig = figure();
    end
    set( fig, 'units', 'normalized' );
    
    % work out the size and spacing
    axwidth  = (1 - xmar - xpad)/ncols;
    axheight = (1 - ymar - ypad)/nrows;
    
    xspace = 0;
    yspace = 0;
    
    if ncols > 1, xspace = xpad / (ncols-1); end
    if nrows > 1, yspace = ypad / (nrows-1); end
    
    % work out the position of each axes
    axpos = cell(nrows,ncols);
    for c = 1:ncols
        
        left = xmar/2 + (c-1)*( axwidth + xspace );
        for r = nrows:-1:1    
            bottom = ymar/2 + (nrows-r)*( axheight + yspace );
            axpos{r,c} = [ left, bottom ];
        end
        
    end
    
    % create them
    ax = gobjects(nrows,ncols);
    for r = 1:nrows
    for c = 1:ncols
        ax(r,c) = axes( ...
            'Position', horzcat(axpos{r,c},[axwidth,axheight]), ...
            'GridLineStyle', 'none', 'Xtick', [], 'Ytick', [], ...
            'XTickLabel', '', 'YTickLabel', '' ...
        );
    end
    end

end