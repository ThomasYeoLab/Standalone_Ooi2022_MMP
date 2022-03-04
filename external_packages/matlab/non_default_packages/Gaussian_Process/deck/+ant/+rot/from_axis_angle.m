function R = from_axis_angle( axis, angle )
% Rotation matrix corresponding to rotating of angle radians around axis.
% Usage: R = rotation.from_axis_angle( axis, angle ); % angle in radians!

    u = axis / norm(axis);
    c = cos(angle);
    d = 1-c;
    s = sin(angle);
    
    x = u(1);
    y = u(2);
    z = u(3);
    
    R = [ x*x*d +   c , x*y*d - z*s , x*z*d + y*s ; ...
          y*x*d + z*s , y*y*d +   c , y*z*d - x*s ; ...
          z*x*d - y*s , z*y*d + x*s , z*z*d +   c ];

end
