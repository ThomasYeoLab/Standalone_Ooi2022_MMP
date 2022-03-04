function y = fhandle(varargin)
%
% y = fhandle( f )
% y = fhandle( f1, f2, ... )
%
% Check if input(s) is/are function handles.
%

    y = dk.mapfun( @(x) isa(x,'function_handle'), varargin, true );
end