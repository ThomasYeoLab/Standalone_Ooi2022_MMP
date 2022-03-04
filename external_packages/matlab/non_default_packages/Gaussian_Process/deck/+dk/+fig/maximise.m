function maximise( f )
% 
% maximise( f )
%
% Maximise figure f (without changing screen).
%
% JH

    u = get(f,'units'); set(f,'units','pixels');
    [~,~,sn] = dk.fig.position(f);
    s = get( 0, 'MonitorPositions' );
    set( f, 'outerposition', s(sn,:) );
    set(f,'units',u);

end
