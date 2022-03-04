function names = search( dirname, expr, filter, recursive )
%
% names = dk.fs.search( dirname, expr, filter=@(x)true, recursive=true )
%
% Return absolute paths to files or folders matching the input regexp.
% Optionally specify a filter function, which takes a listing struct, and returns a boolean.
% For example: filter = @(x) ~x.isdir
%
% NOTE:
%   - The output paths are ABSOLUTE.
%   - Folders . and .. are excluded from all search.
%   - If empty, dirname defaults to pwd.
%   - This implementation is NOT resistant to symbolic loops.
%
% See also: dk.fs.match, dk.fs.walk, regexp
%
% JH

    if nargin < 4, recursive=true; end
    if nargin < 3, filter=@(x) true; end
    if isempty(dirname), dirname=pwd; end
    
    assert( all(dk.is.string( dirname, expr )) && dk.is.fhandle(filter), 'Unexpected input type(s).' );
    
    fmap = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );
    function ok = callback(r,f,d)
        % prevents symbolic loops, but is really slow...
        %r = dk.fs.realpath(r); 
        
        ok = ~fmap.isKey(r);
        if ~ok, return; end
        
        L = [f;d]; % concatenate files and folders
        L = L(arrayfun( @(x) ~isempty(regexp( x.name, expr, 'once' )) && filter(x), L ));
        fmap(r) = dk.mapfun( @(x) fullfile(x.folder,x.name), L, false );
    end
    dk.fs.walk( dirname, @callback, recursive );
    
    names = fmap.values();
    names = vertcat(names{:});

end