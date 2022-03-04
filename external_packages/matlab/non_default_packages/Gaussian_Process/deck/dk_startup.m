function dk_startup()

    here = fileparts(mfilename('fullpath'));
    dk.print('[Deck] Starting up from folder "%s".',here);
    dk.env.path_flag( 'DECK_ROOT', here );
    
    % add GUI library
    layoutSrc = fullfile( here, 'gui', 'layout' );
    layoutDoc = fullfile( here, 'gui', 'layoutdoc' );
    try
        safe_addpath(layoutSrc);
        safe_addpath(layoutDoc);
    catch
        warning( 'GUI layout folder is missing, please run script "extract.sh" in folder "%s".', fullfile(here,'gui') );
    end
    
    % add JMX library
    addpath(fullfile( here, 'jmx' ));

    % set console encoding
    try
        slCharacterEncoding('UTF-8');
    catch 
        warning('Could not set character encoding; is Simulink installed?');
    end

end

function safe_addpath(d)
    assert( dk.fs.isdir(d), 'Folder not found: "%s"', d );
    addpath( d );
end
