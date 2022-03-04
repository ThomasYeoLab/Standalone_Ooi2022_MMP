function [x,y,z,ax] = ginput_surf(n)
%
% [x,y,z,ax] = ginput_surf(n)
%
% Ginput that works on surface plots.
%
% NOTE:
% Contrary to dk.ui.ginput, this method is unable to return information about the button pressed.
%
% See also: ginput
%
% JH

    x  = zeros(n,1);
    y  = zeros(n,1);
    z  = zeros(n,1);
    ax = cell(n,1);
    
    dcm = datacursormode(gcf);
    set( dcm, 'SnapToDataVertex', 'off', 'Enable', 'on', 'DisplayStyle', 'window', 'UpdateFcn', @(varargin)('') );
    
    for i = 1:n
        if ~waitforbuttonpress
            c     = getCursorInfo(dcm);
            x(i)  = c.Position(1);
            y(i)  = c.Position(2);
            z(i)  = c.Position(3);
            ax{i} = gca;
        end
    end
    
    if n == 1, ax = ax{1}; end
    drawnow; set( dcm, 'Enable', 'off' );

end
