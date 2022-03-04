function c = to_cell( s, recursive )
%
% c = dk.struct.to_cell( s, recursive=false )
%
% Build a cell { key1, value1, ... } from input scalar structure.
% Struct-arrays are not supported.
%
% JH

    assert( numel(s) == 1, 'Struct-arrays not supported.' );
    if nargin < 2, recursive = false; end

    f  = fieldnames(s);
    nf = length(f);
    c  = cell(1,2*nf);

    for i = 1:nf

        c{2*i-1} = f{i};
        c{2*i  } = s.( f{i} );

        if recursive && isstruct(c{2*i}) && numel(c{2*i}) == 1
            c{2*i} = dk.struct.to_cell( c{2*i} );
        end

    end

end
