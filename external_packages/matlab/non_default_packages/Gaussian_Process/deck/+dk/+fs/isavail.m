function [ok,reason] = is_safename( name )

    ok     = false;
    reason = ['Name "' name '" exists as a '];
    
    if dk.fs.isfile(name), reason=[reason 'file.']; return; end
    if dk.fs.isdir(name),  reason=[reason 'directory.']; return; end
    
    ok     = true;
    reason = '';
    
end
