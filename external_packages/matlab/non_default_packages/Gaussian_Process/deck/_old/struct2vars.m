function varargout = to_vars( s, varname_handle )
%
% varargout = dk.struct.to_vars( s, varname_handle )
%
% Define the fields of a named structure as variables in the calling function (or console).
% For instance:
%   a = struct('foo',1,'bar','baz');
%   dk.struct.to_vars( a );
%
% will create variables foo=1 and bar='baz' in the caller's scope.
% The second argument (function handle), can be used to edit the
% variable names. For instance:
%   dk.struct.to_vars( a, @(x) ['tmp_' x] );
%
% will create variables tmp_foo and tmp_bar instead.
%
% JH

    if nargin < 2, varname_handle = @(x) x; end

    % get input variable name
    s_name = inputname(1);
    assert( ~isempty(s_name), 'Unnamed variables (ie temporaries) are not supported.' );

    % extract inputs fields
    fields = fieldnames(s);
    n = numel(fields);

    % for each field, append the corresponding variable assignment
    eval_str = '';
    for i = 1:n
        field    = fields{i};
        vname    = varname_handle(field);
        eval_str = [eval_str, vname '=' s_name '.' field '; ' ];
    end

    if nargout > 0
        varargout{1} = eval_str;
    else
        evalin( 'caller', eval_str );
    end

end
