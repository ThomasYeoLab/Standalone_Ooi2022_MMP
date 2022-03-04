function varargout = extract( in, varargin )
%
% [v1,v2, ...] = dk.struct.extract( in, field1, field2, ... )
%
% Forward the values of specified fields to output variables.
% Analogous to a deal() function for scalar structures.
%
% JH

    f = dk.unwrap(varargin);
    n = numel(f);
    
    assert( iscellstr(f), 'Fieldnames should be strings.' );
    assert( dk.is.struct(in,f), 'This function only works with scalar struct.' );
    
    varargout = cell(1,n);
    for i = 1:n
        varargout{i} = in.(f{i});
    end

end