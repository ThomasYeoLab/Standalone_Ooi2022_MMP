function y = string(varargin)
%
% Check whether inputs are strings.
% Returns false for non-row char matrices.
%
% JH

    y = dk.mapfun( @(x) ischar(x) & isrow(x), varargin, true );
end