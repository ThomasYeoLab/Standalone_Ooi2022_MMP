function path_flag( name, target )
%
% dk.env.path_flag( name, target )
%
% This function allows libraries/toolboxes to set a flag to point to a target path.
% If derived paths are found on the Matlab path, they are removed.
%
% JH
    
    flag = getenv( name );
    if ~isempty(flag) && ~strcmp(flag,target)
        warning( 'Flag "%s" already defined, and pointing to: "%s"\nChanging to "%s" instead...', name, flag, target );
        dk.env.clearpath(flag);
    end
    setenv( name, target );
    
end