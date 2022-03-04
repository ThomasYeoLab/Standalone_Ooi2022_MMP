function install( bindir )

    assert( isunix(), 'Sorry, this submodule only works on Unix systems.' );

    % default to $HOME/.local/bin
    if nargin < 1
        bindir = fullfile(dk.env.home,'.local','bin');
        warning( 'No target directory selected, selecting "%s" by default.', bindir );
    end
    if ~dk.fs.isdir(bindir)
        dk.assert( mkdir(bindir), 'Could not create directory "%s".', bindir );
    end

    % move Python scripts there and make them executable
    pyfolder = fullfile( dk.mapred.path, 'python' );
    pyfiles  = dir(fullfile( pyfolder, '*.py' ));
    for i = 1:numel(pyfiles)
        f = pyfiles(i).name;
        dk.assert( copyfile(fullfile(pyfolder,f),fullfile(bindir,f)), 'Could not copy file "%s".', f );
        fileattrib( fullfile(bindir,f), '+x' );
    end

    % Show message about adding to PATH
    fprintf([ '\n' ...
        'Installation complete. The python routines were copied to folder "%s" and made executable.\n\n' ...
        'If you will only call these routines from Matlab (using !command), then add the following line to your startup.m file:\n' ...
        '\t setenv(''PATH'',[strrep(''%s'','' '',''\\ ''),pathsep,getenv(''PATH'')])\n\n' ...
        'Otherwise, if you will use these routines from the terminal, then add the following line to your ~/.bash_profile:\n' ...
        '\t export PATH="%s":${PATH}\n\n' ...
    ],bindir,bindir,bindir);
    
end
