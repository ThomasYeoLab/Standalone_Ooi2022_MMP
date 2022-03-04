function resize( f, height, width )
% 
% dk.fig.resize( f, [h,w] )
% dk.fig.resize( f, h, w )
%
% Resize the window of figure "fig" to a given size.
% If both sizes are between 0 and 1, the sizes are interpreted relative 
% to the current screen size.
% 
% JH

    if nargin > 2 && islogical(width)
        inner = width;
    else
        inner = false;
    end
    if nargin == 2
        switch numel(height)
            case 1
                width = height;
            case 2
                width = height(2);
                height = height(1);
            otherwise
                error( 'Bad size.' );
        end
    end
    assert( all(dk.is.number(height,width)), 'Bad size.' );
    
    [~,hw,sn] = dk.fig.position(f);
    si = dk.screen.info(sn);
    
    if isempty(height)
        if width > 1
            height = hw(1);
        else
            height = hw(1)/si.size(1);
        end
    end
    if isempty(width)
        if height > 1
            width = hw(2);
        else
            width = hw(2)/si.size(2);
        end
    end
    
    hw = [height,width];
    if all( hw > 1 )
        wh = fliplr(hw);
    else
        wh = fliplr(hw .* si.size);
    end
    
    u = get(f,'units'); 
    set(f,'units','pixels');
    if inner
        set( f, 'innerposition', [ si.centre-wh/2, wh ] );
    else
        set( f, 'position', [ si.centre-wh/2, wh ] );
    end
    set(f,'units',u);

end
