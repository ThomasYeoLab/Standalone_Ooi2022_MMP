function out = filter(in,varargin)
%
% out = dk.struct.filter( in, field1, field2, ... )
%
% Filter specified fields from input structure s.
% Works with struct-arrays.
%
% JH

    f = dk.unwrap(varargin);
    
    assert( iscellstr(f), 'Fieldnames should be strings.' );
    assert( isstruct(in), 'First input should be a structure.' );
    out = impl2(in,f);

end

function out = impl1(in,f)
    n = numel(f);
    out = cell([ numel(f), numel(in) ]);
    for i = 1:n
        [out{i,:}] = in.(f{i});
    end
    out = cell2struct( out, f(:), 1 );
    out = reshape( out, size(in) );
end

function out = impl2(in,f)
    out = rmfield( in, setdiff(fieldnames(in),f) );
end