function walk( folder, callback, recursive )
%
% dk.fs.walk( folder, callback, recursive=true )
%
% Explore input folder and invoke callback function for each subfolder with:
%   callback( files, folders, root )
%   
% where
%   root        "current" folder, containing the following files and subfolders
%   files       listing of files (struct-array, cf dir)
%   folders     listing of subfolders (struct-array, cf dir)
%
% The exploration is done in a breadth-first manner, although the order of folder
% exploration at each level is random.
%
% See also: dir
%
% JH

    if nargin < 3, recursive=true; end

    next = { folder };
    while ~isempty(next)
        cur = next;
        next = {};
        
        ncur = numel(cur);
        for i = 1:ncur
            ci = cur{i};
            
            lst = dir(ci);
            lst = lst(~ismember( {lst.name}, {'.','..'} ));
            lst = lst(:)';
            
            dmask = [lst.isdir];
            dlst = lst(dmask);
            callback( ci, lst(~dmask), dlst );
            
            next = [next, dk.mapfun( @(x) fullfile(ci,x), {dlst.name}, false )];
        end
        
        if ~recursive, break; end
    end

end