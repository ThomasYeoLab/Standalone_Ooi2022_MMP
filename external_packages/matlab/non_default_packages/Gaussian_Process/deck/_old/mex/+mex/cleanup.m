function cleanup( folder, type )

    if nargin < 2, type='all'; end

    switch lower(type)
        
        case 'all'
            dk.mex.cleanup( folder, 'mex' );
            dk.mex.cleanup( folder, 'obj' );
            return;
            
        case 'mex'
            files = dk.fs.lsext( folder, mexext );
            print = @(x) dk.info('[dk.mex.cleanup] Removing mex-file "%s"',x);
            
        case 'obj'
            files = dk.fs.lsext( folder, 'o' );
            print = @(x) dk.info('[dk.mex.cleanup] Removing object-file "%s"',x);
        
        otherwise
            error( 'Unknown source type "%s".', type );
            
    end
    
    for i = 1:length(files)
        f = fullfile( folder, files{i} ); 
        print(f); delete(f);
    end
    
end
