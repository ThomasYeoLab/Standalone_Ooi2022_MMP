function [center,normal] = fit_plane( points )
% [center, normal] = fit_plane( points )
%
% Return the least-square fit of a plane through the points using SVD.
%
% Inputs:
%   points is a nx3 matrix of coordinates row by row.
%
% Output:
%   center is the barycenter of points, normal is the normal to the fitted plane.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    assert( ismatrix(points) && size(points,2) == 3, 'points must be nx3.' );

    % Find the least square fit
    center  = mean(points);
    points  = bsxfun( @minus, points, center );
    [u,~,~] = svd(points');
    normal  = u(:,3)';
    
    % Normalize the normal to the plane
    normal = normal / norm(normal);

end
