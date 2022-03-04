function [h,A] = alphashape( X, varargin )
%
% [h,A] = dk.ui.alphashape( X, varargin )
%
% This method is appropriate if the set of points in X (which should be nx3) represents a VOLUME SCATTER.
% If the set of points represent a surface, which you want to triangulate, you should use dk.ui.triangulation instead.
%
% See also: dk.ui.convhull, alphaShape
%
% JH

    assert( size(X,2)==3, 'Input should be nx3' );
    
    A = alphaShape(X(:,1), X(:,2), X(:,3));
    h = A.plot( varargin{:} );

end
