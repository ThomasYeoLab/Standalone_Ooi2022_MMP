function v = values( s, order )
%
% v = dk.struct.values( s, order={} )
%
% Returns a N x M cell-array where N is the size of the input struct-array and M is the number of fields.
% Cell (i,j) contains the value of j^th field in the i^th structure.
%
% If order is specified as a cell-string of fieldnames, then the order of output columns is set accordingly.
% Non-existing fields are ignored SILENTLY (please check that you have the right number of fields in output).
%
% JH

    f = fieldnames(s);
    if nargin > 1
        f = intersect( order, f, 'stable' );
    end
    
    nstruct = numel(s);
    nfields = numel(f);
    v = cell( nstruct, nfields );

    for i = 1:nstruct
    for j = 1:nfields
        v{i,j} = s(i).(f{j});
    end
    end

end
