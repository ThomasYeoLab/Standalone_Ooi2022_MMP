function sc = movetoscreen( f, num )
%
% sc = movetoscreen( f, num )
%
% Move figure to specified screen, and return pixel coordinates of screen centre.
%
% JH

    [~,hw] = dk.fig.position(f);
    sc = dk.screen.centre(num);
    wh = fliplr(hw);
    
    u = get(f,'units'); set(f,'units','pixels');
    set( f, 'outerposition', [ sc-wh/2, wh ] );
    set(f,'units',u);

end