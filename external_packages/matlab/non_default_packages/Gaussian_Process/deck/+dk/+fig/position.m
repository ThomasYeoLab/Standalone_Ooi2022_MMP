function [cp,hw,sn] = position(f,inner)
%
% [cp,hw,sn] = dk.fig.position( f, inner=false )
%
% cp : center pixel
% hw : height x width
% sn : screen number
%   

    if nargin < 2, inner=false; end

    u = get( f, 'units' ); set( f, 'units', 'pixels' );
    if inner
        p = get( f, 'innerposition' );
    else
        p = get( f, 'outerposition' );
    end
    
    % compute coordinates of center pixel
    cp = p(1:2) + p(3:4)/2;
    
    % height and width
    hw = [p(4) p(3)];
    
    % find out in which screen the figure is in
    s  = get( 0, 'MonitorPositions' );
    n  = size(s,1);
    d  = inf(1,n);
    sn = 0;
    
    for i = 1:n
        x = s(i,:);
        d(i) = norm( cp - (x(1:2) + x(3:4)/2) ); % distance between screen centre and figure centre
        if (cp(1) >= x(1)) && (cp(1) <= x(1)+x(3)) && (cp(2) >= x(2)) && (cp(2) <= x(2)+x(4))
            sn = i; break; % if figure centre within bounds of screen i, then select that screen
        end
    end
    if sn == 0 % otherwise, select the closest screen
        [~,sn] = min(d);
    end
    
    % restore figure units
    set( f, 'units', u );
    
end