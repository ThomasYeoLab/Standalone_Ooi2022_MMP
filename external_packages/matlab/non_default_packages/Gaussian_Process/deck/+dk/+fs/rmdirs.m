function rmdirs( fpath, misok, ntry )
%
% dk.fs.rmdirs( fpath, okIfMissing=true, retry=5 )
%
% Variant of dk.fs.rmdir for non-empty folders.
%
% See also: dk.fs.rmdir, dk.trywait
%
% JH

    if nargin < 3, ntry=5; end
    if nargin < 2, misok=true; end

    if ~dk.fs.isdir(fpath)
        assert( misok, 'Folder already exists.' );
        return;
    end
    
    function callable()
        [s,m,k] = rmdir(fpath,'s');
        assert( s == 1, 'Could not remove folder: %s', fpath );
    end

    twait = 15;
    errmsg = sprintf( 'Failed attempt, waiting %d seconds before retrying.', twait );
    dk.trywait( ntry, twait, @callable, errmsg );

end
