function clus = init_parpool( nworkers )
%
% Initialize Matlab parallel pool with n workers.
%
% JH
    
    % Old and new version of cluster management
    if dk.chkmver(2014)
        
        % Get cluster config
        cfg  = defaultParallelConfig();
        clus = parcluster( cfg );
        
        % Delete old jobs if any
        if ~isempty(clus.Jobs)
            delete( clus.Jobs );
        end
        clus = parcluster( cfg );
        
        % Create new pool
        matlabpool(clus,nworkers);
        
    else
        
        % Get cluster config
        cfg  = parallel.defaultClusterProfile;
        clus = parcluster( cfg );

        % Delete old jobs if any
        if ~isempty(clus.Jobs)
            delete( clus.Jobs ); % maybe not?
        end
        clus = parcluster( cfg );

        % Create new pool
        parpool(clus,nworkers);
        
    end

end
