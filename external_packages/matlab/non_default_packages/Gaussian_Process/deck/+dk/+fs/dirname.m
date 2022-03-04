function d = dirname( x, n )
%
% d = dk.fs.dirname( x, n=0 )
%
% Return directory part in input path x:
%   - if the last segment of x has a dot, interpret as basename and ignore;
%   - if x is empty (either no input, or after previous step), take pwd;
%   - if n > 0, remove the last n segments.
%
% JH

    if nargin < 2, n=0; end
    
    % trim and handle empty strings
    x = strtrim(x);
    if isempty(x)
        x = pwd();
    end
    
    % if the last part has an extension, assume it is a file and remove it
    x = strsplit( x, filesep );
    if ~isempty(regexp( x{end}, '\.\S+$' ))
        x = x(1:end-1);
    end
    
    % assume pwd if nothing remains
    if isempty(x)
        x = strsplit( pwd, filesep );
    end
    
    % remove requested number of folders
    d = strjoin( x(1:end-n), filesep );

end