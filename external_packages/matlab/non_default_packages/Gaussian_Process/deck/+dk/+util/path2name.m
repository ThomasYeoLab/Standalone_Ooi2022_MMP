function cname = path2name(fpath)
%
% cname = path2name(fpath)
%
% Takes a file path and return the name of the corresponding function
% resolving intermediary submodules.
%
% Example:
%
%   dk.util.path2name( dk.path('+fs/list_dir.m') ) => dk.fs.lsdir
% 
% JH

    segments = strsplit(fpath,filesep);
    withplus = cellfun(@(s) ~isempty(s) && s(1)=='+',segments);
   
    % find first segment
    first = numel(withplus);
    while (first > 1) && withplus(first-1)
        first = first-1;
    end
    
    cname = strjoin([ ...
        dk.mapfun(@(s) s(2:end),segments(first:end-1),false), ... remove +
        { dk.str.xrem(segments{end},'.m') } ... remove extension
    ], '.');

end
