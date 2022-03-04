function files = list_files( dirname, pattern )
%
% List files in dirname matching pattern (default: non-hidden).
%
% JH

    if nargin < 1 || isempty(dirname), dirname=pwd; end
    if nargin < 2, pattern = '^[^\.].*'; end
    
    % undocummented feature
    if islogical(dirname)
        dirname = pwd;
        if dirname, pattern = '.*'; end
    end

    files = dk.fs.match( dirname, pattern, @(x) ~x.isdir );

end
