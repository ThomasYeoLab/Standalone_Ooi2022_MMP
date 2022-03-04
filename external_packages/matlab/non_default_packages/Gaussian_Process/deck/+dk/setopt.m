function out = setopt( out, varargin )
%
% opt = dk.setopt( opt, Field1, Value1, Field2, ... )
%
%   A simple function to assign fields in a given struct of options.
%
%
% NOTE
% ----
%
%   Option names are case-sensitive
%   Duplicate fields are fine (overwrite r2l)
%   Cell-values do not need to be wrapped
%
% EXAMPLE
% -------
%
%   % default options
%   opt.foo = 5;
%   opt.bar = 'hi';
%
%   % ... later on
%   opt = dk.setopt( opt, 'foo', 1, 'baz', {1,2,3} );
%
%
% See also: dk.getopt
%
% JH

    in = dk.c2s( varargin );
    if isempty(out)
        out = struct();
    end
    
    scalar_struct = @(x) assert( isstruct(x) && isscalar(x), 'Expected a scalar structure.' );
    scalar_struct(in);
    scalar_struct(out);

    out = dk.struct.merge( out, in );
    
end