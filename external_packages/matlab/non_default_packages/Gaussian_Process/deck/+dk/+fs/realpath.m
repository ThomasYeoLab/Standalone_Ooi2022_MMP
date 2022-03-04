function p = realpath(name)
    
    % using Python
    [~,p] = system(sprintf('python %s "%s"',fullfile(dk.path,'realpath'),name));
    
    % This does not work for file links:
    %[s,p] = system(sprintf('cd "%s" && pwd -P',name)); 
    %dk.assert( s==0, 'Path not found: "%s".', name );
    
    p = deblank(p);
    
end
