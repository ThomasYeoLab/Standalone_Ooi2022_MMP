function s = repeat( fields, varargin )
%
% s = dk.struct.repeat( fields, varargin )
%
% Create a struct-array with specified fields.
% This is equivalent to repmat( struct('field1',[],'field2',[],...), varargin{:} ).
%
% JH

    assert( iscellstr(fields), 'Expects a cell of fieldnames in input.' );
    assert( nargin > 1, 'Expects an array size in input.' );

    n = numel(fields);
    f = cell(1,2*n);
    f(1:2:end) = fields;

    s = repmat( struct(f{:}), varargin{:} );

end
