function folders = list_folders( dirname, pattern )
%
% List folders in dirname matching the input pattern (default: non-hidden).
%
% JH

    if nargin < 1 || isempty(dirname), dirname=pwd; end
    if nargin < 2, pattern = '^[^\.].*'; end
    
    % undocummented feature
    if islogical(dirname)
        dirname = pwd;
        if dirname, pattern = '.*'; end
    end

    folders = dk.fs.match( dirname, pattern, @(x) x.isdir );
    
end
