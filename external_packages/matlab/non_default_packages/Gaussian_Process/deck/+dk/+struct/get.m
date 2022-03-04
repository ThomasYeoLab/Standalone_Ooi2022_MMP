function default = get( s, field, default )
%
% val = dk.struct.get( s, field, default )
%
% Get a field value from a structure or struct-array.
% If the field does not exists, and that a default value is specified,
% the default value is returned instead.
%
% If the input is a struct array, the output is a cell of the same size,
% even if the field does not exist (default value is repeated).
%
% JH

    n = numel(s);
    if isfield(s,field)
        if n > 1
            default = reshape( {s.(field)}, size(s) );
        else
            default = s.(field);
        end
    elseif n > 1
        default = repmat( {default}, size(s) );
    end

end
