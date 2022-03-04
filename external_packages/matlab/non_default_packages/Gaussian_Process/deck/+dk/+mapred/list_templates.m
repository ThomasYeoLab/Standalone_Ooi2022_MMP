function L = list_templates()

    L = dir(fullfile( dk.mapred.path, 'templates', '*.m' ));
    
    if nargout == 0
        L = dk.mapfun( @(x) dk.str.xrem(x.name,1), L, false );
        dk.print('Found %d template(s):',numel(L));
        cellfun( @(x) fprintf('\t%s\n',x), L );
    end

end
