function h = menu_ginput( callback, parent, label, surf )
%
% h = dk.widget.menu_ginput( callback, parent=gcf, label=Select, surf=false, snap=[] )
%
% Adds a menu entry to a figure which triggers ginput (mouse selection tool).
%
% The callback function is invoked with the selected coordinates, as well as 
% the axes in which the selection occured. Note that the callback is invoked
% ONLY if a selection is made, and not if the selection is canceled. 
% The signature of the callback function should be:
%   callback( x, y, axes )    % surf=false
%   callback( x, y, z, axes ) % surf=true
% where axes is the handle where the selection occured.
%
% Set the surf flag to true if the selection is to be made on a surface, as
% opposed to a plot or an image.
%
% The menu entry can be nested into an existing menu, by setting the parent
% as the handle of the nested menu. For example, if the selection menu should 
% appear in 
%   First > Second > Select
% then parent should be the handle of Second.
%
% JH

    if nargin < 4, surf=false; end
    if nargin < 3, label='Select'; end
    if nargin < 2, parent=gcf; end
    
    assert( ishandle(parent), 'Parent should be a valid handle.' );
    assert( ischar(label), 'Label should be a string.' );
    assert( isa(callback,'function_handle'), 'Callback should be a function handle.' );
    
    fig = ancestor( parent, 'figure' );
    function local_callback(varargin)
        
        figure(fig); % select figure in which the menu is
        if surf
            [x,y,z,ax] = dk.ui.ginput_surf(1);
            arg = {x,y,z,ax};
        else
            [x,y,ax] = dk.ui.ginput(1);
            arg = {x,y,ax};
        end
        
        if x, callback(arg{:}); end
        
    end
    h = uimenu(parent,'label',label,'callback',@local_callback);

end