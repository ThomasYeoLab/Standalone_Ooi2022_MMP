function walk( folder, callback, recursive )
%
% dk.fs.walk( folder, callback, recursive=true )
%
% Explore input folder and invoke callback function for each subfolder with:
%   ok = callback( root, files, folders )
%   
% where
%   root        "current" folder, containing the following files and subfolders
%   files       listing of files (struct-array, cf dir)
%   folders     listing of subfolders (struct-array, cf dir)
%
% The callback should return false to abort further recursions (e.g. enforcing
% maximum depth, or preventing symbolic loops). The exploration is done in a 
% depth-first manner, but the order of folderexploration at each level is random.
%
% See also: dir
%
% JH

    if nargin < 3, recursive=true; end
    
    item = dir(folder);
    item = item(~ismember( {item.name}, {'.','..'} ));
    dmask = [ item.isdir ];
    dlist = item(dmask);
    
    % abort traversal if callback returns false
    if ~callback( folder, item(~dmask), dlist ) || ~recursive
        return;
    end
    
    % otherwise, explore children folders
    n = numel(dlist);
    for i = 1:n
        dk.fs.walk( fullfile(folder,dlist(i).name), callback, recursive );
    end

end