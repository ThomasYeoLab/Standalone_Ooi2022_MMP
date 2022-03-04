function out = kvfun( fun, s, type )
%
% out = dk.kvfun( fun, s, type=array )
%
% Variant of Matlab's structfun, which applies a function to each field of a struct-array.
% fun should be a function handle with TWO arguments:
%   fun( fieldname, fieldvalue )
%
% If type=array (default), the output is an array with 
%   N rows = number of structures
%   F cols = number of fields. 
% For example, calling with a scalar struct yields a row-vector.
%
% If type=cell, the output is a NxF cell array.
% If type=table, the output is a table with N records.
% If type=struct, the output is assigned back to a struct.
%
% It is fine if fun does not return anything, but then you should not collect an output.
% 
% JH

    assert( isstruct(s), 'Second argument should be a structure.' );
    assert( isa(fun,'function_handle'), 'First argument should be a function handle.' );
    if nargin < 3, type='array'; end % array output by default

    n = numel(s);
    f = fieldnames(s);
    m = numel(f);

    if nargout > 0
        out = cell(n,m);
        for i = 1:n % structures
        for j = 1:m % fields
            out{i,j} = fun( f{j}, s(i).(f{j}) );
        end
        end
        
        % post-formatting
        switch lower(type)
            case 'cell' % nothing to do
            case 'array'
                out = cell2mat(out);
            case 'table'
                out = cell2table( out, 'VariableNames', f );
            case 'struct'
                out = cell2struct( out, f, 2 );
            otherwise
                error( 'Unknown output type: %s', type );
        end
    else
        for i = 1:n % structures
        for j = 1:m % fields
            fun( f{j}, s(i).(f{j}) );
        end
        end
    end

end