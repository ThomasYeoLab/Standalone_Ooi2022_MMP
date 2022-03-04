function [V,F] = cloud2mesh(X,varargin)
%
% [V,F] = cloud2mesh(X,varargin)
%
% Equivalent to alphaShape(double(X),varargin{:}).boundaryFacets()
% Facets indices are converted to uint32.
%
% JH

    assert( ismatrix(X) && isnumeric(X) && size(X,2)==3, 'X should be a Nx3 matrix of coordinates.' );
    [F,V] = alphaShape( double(X), varargin{:} ).boundaryFacets();
    F = uint32(F);

end