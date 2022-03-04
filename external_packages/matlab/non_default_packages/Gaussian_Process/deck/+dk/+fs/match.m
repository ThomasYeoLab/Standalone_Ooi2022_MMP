function names = match( dirname, expr, filter )
%
% names = dk.fs.match( dirname, expr, filter=@(x)true )
%
% List relative paths of files or folders in dirname matching the input regexp.
% Optionally specify a filter function, which takes a listing struct, and returns a boolean.
% For example: filter = @(x) ~x.isdir
%
% NOTE:
%   - The search is NOT recursive.
%   - The ouput paths are RELATIVE.
%   - Folders . and .. are excluded from all search. 
%   - If empty, dirname defaults to pwd.
%
% See also: dk.fs.search, regexp, dir
%
% JH

    if isempty(dirname), dirname=pwd; end
    if nargin < 3, filter = @(x) true; end
    
    assert( all(dk.is.string( dirname, expr )) && dk.is.fhandle(filter), 'Unexpected input type(s).' );

    props = dir( dirname ); 
    names = { props.name };
    valid = @(x) ...
        ~any(strcmp( x.name, {'.','..'} )) && ...
        ~isempty(regexp( x.name, expr, 'once' )) && ...
        filter(x);
    
    names = names(arrayfun( valid, props ));

end
