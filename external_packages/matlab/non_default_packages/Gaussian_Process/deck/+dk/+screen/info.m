function I = info( num )
%
% Return center position and size (in pixels) for each screen.
%
% JH

    s = get( 0, 'MonitorPositions' );
    n = size(s,1);
    I = dk.struct.repeat( {'size','centre'}, 1, n );
    
    for k = 1:n
        I(k).size   = [s(k,4),s(k,3)]; % height x width
        I(k).centre = s(k,1:2) + s(k,3:4)/2;
    end

    if nargin > 0
        I = I(num);
    end
    
end