function disp(s)
%
% dk.struct.disp(s)
%
% Display a flat structure nicely in the console.
%
% JH

    assert( dk.is.struct(s), 'Input should be a scalar struct.' );

    f = fieldnames(s);
    w = max(cellfun( @length, f )) + 2;
    n = numel(f);
    for i = 1:n
        dispfield( f{i}, w );
        dispvalue( s.(f{i}) );
    end

end

function dispfield(f,w)
    n = length(f);
    fprintf( [ repmat(' ',1,w-n), f, ': ' ] );
end

function dispvalue(v)
    assert( ~isstruct(v) && ~iscell(v), 'Unsupported value type.' );
    if isnumeric(v) && ~isscalar(v)
        assert( isvector(v), 'Unsupported array shape.' );
        v = dk.util.array2str(v);
    end
    if isnumeric(v), v = num2str(v); end
    if islogical(v), v = dk.util.bool2str(v); end
    fprintf( '%s\n', deblank(v) );
end
