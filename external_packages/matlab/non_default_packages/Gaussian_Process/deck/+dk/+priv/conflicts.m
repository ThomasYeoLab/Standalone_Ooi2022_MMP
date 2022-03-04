function conflicts( folders, recursive )
%
% Check for name-conflicts in input folder(s).
%
% JH
    
    if nargin < 2, recursive=true; end

    if iscell(folders)
        assert( all(cellfun( @isdir, folders )), 'One or more input folder does not exist.' );
        list = folders;
    else
        assert( isdir(folders), 'Input folder does not exist.' );
        list = {folders};
    end
    
    while ~isempty(list)
        current = list{1};
        if recursive
            list = [ list(2:end), find_subfolders(current) ];
        end
        check_folder(current);
    end
    
end

function y = basename(x)
    [~,y] = fileparts(x);
end

function y = valid_folder(x)
    y = (x(1) ~= '.') && (x(1) ~= '+') && (x(1) ~= '@');
end

function sub = find_subfolders(folder)
    sub = dir(folder);
    sub = {sub([sub.isdir]).name};
    sub = sub(cellfun( @valid_folder, sub ));
    sub = dk.mapfun( @(x)fullfile(folder,x), sub, false );
end

function out = check_folder(folder)

    fprintf('# Checking folder "%s"... ',folder);
    
    % make sure folder is not on path
    restore = false;
    folder  = dk.fs.realpath(folder);
    if ~isempty(strfind(path,folder)) %#ok
        rmpath(folder);
        restore = true;
    end
    
    % list m-scripts and mex-files
    files = dir(fullfile( folder, '*.m' ));
    files = [ files; dir(fullfile( folder, ['*.' mexext] )) ];
    files = dk.mapfun( @basename, {files.name}, false );
    
    existing = dk.mapfun( @which, files, false );
    conflict = cellfun( @(x) ~isempty(x), existing );
    
    if any(conflict)
        
        n = sum(conflict);
        fprintf('%d conflict(s)\n',n);
        
        files = files(conflict);
        existing = existing(conflict);
        for i = 1:n
            fprintf('\t %s <> %s \n',files{i},existing{i});
        end
        
        out = dk.mapfun( @(x) fullfile(folder,x), files, false );
        
    else
        fprintf('ok\n'); out = {};
    end
    
    % restore path
    if restore
        addpath(folder);
    end

end
