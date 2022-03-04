function p = name2relpath( name )
            
    if isempty(strfind(name,'.'))
        p = name;
    else
        p = strsplit( name, '.' );
        p = horzcat( dk.mapfun( @(x) ['+' x], p(1:end-1), false ), p{end} );
        p = fullfile(p{:});
    end

end