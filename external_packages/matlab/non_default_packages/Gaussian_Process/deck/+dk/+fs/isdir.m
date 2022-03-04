function yes = isdir( name )
%
% y = dk.fs.isdir( name )
%
% Check that path is a folder.
% Returns true for empty inputs (assumes '.').
%
% Note: this is not equivalent to isdir or isfolder.
%
% See also: dk.fs.exist
%
% JH

    if isempty(name), name = '.'; end
    yes = dk.fs.exist( name, 'dir' );
end
