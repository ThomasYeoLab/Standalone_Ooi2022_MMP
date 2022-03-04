function mkdir( fpath, exok, ntry )
%
% dk.fs.mkdir( fpath, okIfExists=true, retry=5 )
%
% Variant of mkdir checking for existing target, and allowing to retry if the operation fails.
% This can sometimes happen on network filesystem.
%
% See also: dk.trywait
%
% JH

    if nargin < 3, ntry=5; end
    if nargin < 2, exok=true; end

    if dk.fs.isdir(fpath)
        assert( exok, 'Folder already exists.' );
        return;
    end
    
    function callable()
        [s,m,k] = mkdir(fpath);
        assert( s == 1, 'Could not create folder: %s', fpath );
    end

    twait = 15;
    errmsg = sprintf( 'Failed attempt, waiting %d seconds before retrying.', twait );
    dk.trywait( ntry, twait, @callable, errmsg );

end
