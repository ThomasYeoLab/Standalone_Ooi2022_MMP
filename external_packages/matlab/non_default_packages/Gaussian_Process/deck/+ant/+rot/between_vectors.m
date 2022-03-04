function R = between_vectors( v1, v2 )
% Find rotation matrix from v1 to v2 (column vectors).
% Usage: R = rotation.between_vectors(v1,v2); v3=R*v1; norm( v2/norm(v2) - v3/norm(v3) )

    v1=v1(:); v2=v2(:);
    assert( norm(v1-v2)>eps, 'a and b are too close.' );
    
    cr = cross(v1,v2);
    ag = atan2( norm(cr), sum(v1.*v2) );
    R  = ant.rot.from_axis_angle(cr,ag);

end
