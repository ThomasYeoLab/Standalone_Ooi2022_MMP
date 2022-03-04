function s = make(varargin)
%
% s = dk.struct.make( field1, field2, .. )
% s = dk.struct.make( {field1, field2, ..} )
%
% Create scalar struct with specified fields, and values set to [].
%
% JH

    if nargin == 1 && iscellstr(varargin{1})
        f = varargin{1};
    else
        f = varargin;
    end
    assert( iscellstr(f), 'Input(s) should be strings (or a cell-string).' );
    
    n = numel(f);
    c = cell(1,2*n);
    c(1:2:end) = f;
    s = struct(c{:});
end