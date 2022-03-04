function dk_shutdown()

    root = getenv('DECK_ROOT');
    if dk.fs.isdir(root)
        layoutSrc = fullfile( root, 'gui', 'layout' );
        layoutDoc = fullfile( root, 'gui', 'layoutdoc' );
        jmxSrc = fullfile( root, 'jmx' );
        
        rmpath( jmxSrc, layoutSrc, layoutDoc );
        setenv( 'DECK_ROOT', '' );
        
        dk.print( '[Deck] Shutting down from folder "%s".', root );
    else
        warning( 'Deck does not appear to have started.' );
    end

end
