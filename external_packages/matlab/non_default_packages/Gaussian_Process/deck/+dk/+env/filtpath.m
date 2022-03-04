function p = filtpath( varargin )
%
% p = dk.env.filtpath( folders )
%
% Returns the path after filtering input folder(s) out.
% The Matlab root is always filtered first.
% For each input folder, the corresponding realpath is also checked.
% Folders to be filtered should correspond to some base subdir, that is: 
%   '/Documents/foo' will NOT match '/Users/alice/Documents/foo' 
%   but '/Users/alice' will.
%
% If no output is collected, the remaining folders are printed to the console.
%
% JH

    % list of folders to filter
    folders = varargin;
    assert( iscellstr(folders), 'Input folders should be strings.' );
    folders = horzcat( matlabroot, folders );
    folders = horzcat( folders, dk.mapfun( @dk.fs.realpath, folders, false ) );
    folders = unique( folders );

    % current path
    p = strsplit( path, pathsep );
    p = p(~contains( folders, p ));
    
    % display to console if no output
    if nargout == 0
        cellfun( @disp, p );
    end
    
end

function out = contains( folders, data )

    out = false(size(data));
    n = numel(folders);
    
    for i = 1:n
        out = out | dk.mapfun( @(v) any(v==1), strfind( data, folders{i} ), true );
    end

end