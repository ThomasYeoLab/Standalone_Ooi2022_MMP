function [h,D] = triangulation( X, varargin )
%
% [h,D] = dk.ui.triangulation( X, varargin )
%
% NOTICE:
% This method is only appropriate if the set of points in X (which should be nx3) represents a SURFACE.
%
% If the points are scattered within a volume, which you want to wrap with a surface, then use either 
% dk.ui.convhull or dk.ui.alphashape.
%
% See also: delaunayTriangulation, trisurf 
% Source: http://uk.mathworks.com/matlabcentral/fileexchange/5105-making-surface-plots-from-scatter-data
%
% JH

    assert( size(X,2)==3, 'Input should be nx3.' );
    
    D = delaunayTriangulation(X);
    h = trisurf( D, D.Points(:,1), D.Points(:,2), D.Points(:,3), varargin{:} );
    
end
