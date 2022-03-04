function h = menu_3Dview( ax, label )
%
% h = menu_3Dview( ax=gca, label=Orient )
%
% Adds a menu entry to the figure which contains the input axes.
% The menu allows to rotate an object using natural terms like "front" or "left".
% This can be used with any 3D plot.
%
% JH

    if nargin < 1, ax=gca; end
    if nargin < 2, label='Orient'; end
    
    % find figure
    fig = ancestor( ax, 'figure' );
    
    function local_callback(orient)
        switch lower(orient)
            case 'left'
                o = [ -90, 0 ];
            case 'right'
                o = [ 90, 0 ];
            case 'front'
                o = [ -180, 0 ];
            case 'back'
                o = [ 0, 0 ];
            case 'over'
                o = [ 0, 90 ];
            case 'under'
                o = [ -180, -90 ];
            case {'righttilt','right-tilt','rtilted'}
                o = [ 90, -10 ];
            case {'lefttilt','left-tilt','ltilted'}
                o = [ -90, -10 ];
            case {'backleft','back-left'}
                o = [ -45, 0 ];
            case {'backright','back-right'}
                o = [ 45, 0 ];
            case {'frontleft','front-left'}
                o = [ -135, 0 ];
            case {'frontright','front-right'}
                o = [ -225, 0 ];
            case {'bol','back-over-left'}
                o = [ -45, 20 ];
            case {'bor','back-over-right'}
                o = [ 45, 20 ];
            case {'fol','front-over-left'}
                o = [ -135, 20 ];
            case {'for','front-over-right'}
                o = [ -225, 20 ];
            case {'sideleft','side-left'}
                o = [ -60, 20 ];
            case {'sideright','side-right'}
                o = [ 60, 20 ];
        end
        view(ax,o(1),o(2));
    end

    h = uimenu( fig, 'label', label );
    fig.UserData.orient = @local_callback;
    
    uimenu( h, 'label', 'Left', 'callback', @(varargin) local_callback('left') );
    uimenu( h, 'label', 'Right', 'callback', @(varargin) local_callback('right') );
    uimenu( h, 'label', 'Front', 'callback', @(varargin) local_callback('front') );
    uimenu( h, 'label', 'Back', 'callback', @(varargin) local_callback('back') );
    uimenu( h, 'label', 'Over', 'callback', @(varargin) local_callback('over') );
    uimenu( h, 'label', 'Under', 'callback', @(varargin) local_callback('under') );
    
    uimenu( h, 'label', 'Front-left', 'callback', @(varargin) local_callback('frontleft') );
    uimenu( h, 'label', 'Front-right', 'callback', @(varargin) local_callback('frontright') );
    uimenu( h, 'label', 'Back-left', 'callback', @(varargin) local_callback('backleft') );
    uimenu( h, 'label', 'Back-right', 'callback', @(varargin) local_callback('backright') );
    uimenu( h, 'label', 'Side-left', 'callback', @(varargin) local_callback('sideleft') );
    uimenu( h, 'label', 'Side-right', 'callback', @(varargin) local_callback('sideright') );

end