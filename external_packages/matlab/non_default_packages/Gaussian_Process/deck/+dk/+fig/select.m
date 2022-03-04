function fig = select(h)
%
% fig = dk.fig.select(h)
%
% Change focus to specified axes.
%
% JH

    assert( ishandle(h), 'Input is not a handle.' );

    switch lower(get(h,'Type'))
        case 'figure'
            fig = h;
            
        case 'axes'
            fig = ancestor( h, 'figure' );
            set( fig, 'currentaxes', h );
            
        otherwise
            fig = ancestor( h, 'figure' );
    end
    set( 0, 'currentfigure', fig );
    
end