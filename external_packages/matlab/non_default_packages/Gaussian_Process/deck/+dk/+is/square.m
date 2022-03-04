function y = square( varargin )
%
% y = square( x )
% y = square( x1, x2, ... )
%
% Check if input is a square matrix.
% When several inputs are specified, return a vector of ansers.
%
% JH

    y = dk.mapfun( @(x) ismatrix(x) && diff(size(x))==0, varargin, true );
end