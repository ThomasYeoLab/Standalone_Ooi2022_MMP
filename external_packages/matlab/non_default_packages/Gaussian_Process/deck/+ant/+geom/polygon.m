function x = polygon(n,len)
%
% x = ant.geom.polygon(n,len=[])
%
% Return coordinates of regular polygon with n vertices.
% By default, the side-length is such that the polygon fits within a circle of radius 1.
%
% JH

    t = pi/2 + linspace(0,2*pi,n+1);
    t = t(1:end-1);
    x = [cos(t); sin(t)]';
    
    if nargin > 1
        L = norm(x(2,:) - x(1,:));
        x = x * (len/L);
    end
    
    if nargout == 0
        figure;
        P = vertcat( x, x(1,:) );
        plot( P(:,1), P(:,2), 'k-', 'LineWidth', 3 );
        axis equal off; grid off;
    end
    
end
