function [yes,target] = is_symlink( name )
%
% Check whether the input name is an existing symbolic link (UNIX only).
%
% JH
    
    % Remove trailing separators for directories
    name = dk.str.rstrip( name, filesep );
    
    % Check for link
    s = unix(sprintf('test -L "%s"',name));
    yes = (s == 0);
    
    % Find target
    if yes
        target = strtrim(dk.fs.realpath(name));
    else
        target = '';
    end
    
end
