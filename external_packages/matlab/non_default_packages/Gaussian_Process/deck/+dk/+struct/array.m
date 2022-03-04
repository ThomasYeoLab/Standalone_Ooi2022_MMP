function sa = array( varargin )
%
% s = dk.struct.array( field1, values, field2, ... )
%
% Example:
%   a = dk.struct.array( 'foo.bar', [1 2 3], 'baz', {[0 1], 'hello', struct()} )
%   cellfun( @(x) x.bar, {a.foo} )
%   {a.baz}
%
% JH

    % extract fields and values
    assert( mod(nargin,2) == 0, 'Inputs should be key/values pairs.' );

    nf     = nargin / 2; % number of fields
    fields = varargin(1:2:end);
    values = varargin(2:2:end);

    % make sure there are the same number of values for each field
    sizes = cellfun( @numel, values );
    strval = cellfun( @ischar, values );
    switch sum(~strval)
        case 0 
            ns = 1; % number of structures
        case 1
            ns = sizes(~strval);
        otherwise
            sizes = sizes(~strval);
            ns = sizes(1);
            assert( all(diff(sizes) == 0), ...
                'Values should have the same size for each field.' ); 
    end

    % create empty structure to allocate output
    mock = struct();
    for i = 1:nf
        f    = dk.str.to_substruct(fields{i});
        mock = subsasgn( mock, f, [] );
    end

    % allocate output and assign values for each field
    sa = repmat( mock, ns, 1 );
    for i = 1:nf
        f = dk.str.to_substruct(fields{i});

        if ischar(values{i})
            for j = ns:-1:1, sa(j) = subsasgn( sa(j), f, values{i} ); end
        elseif iscell(values{i})
            for j = ns:-1:1, sa(j) = subsasgn( sa(j), f, values{i}{j} ); end
        else
            for j = ns:-1:1, sa(j) = subsasgn( sa(j), f, values{i}(j) ); end
        end
    end

end
