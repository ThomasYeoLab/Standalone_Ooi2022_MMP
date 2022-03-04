function str = xset( str, ext, dotc )
%
% str = dk.str.xset( str, ext, dotc='.' )
%
% Add suffix extension to string if it is not already set.
%
% JH

    if nargin < 3, dotc = '.'; end

    % set a leading dot to the extension
    if ext(1) ~= dotc, ext=[dotc ext]; end

    % check whether the extension is already set
    l = numel(ext);
    if numel(str)<l || ~strcmpi( str(end-l+1:end), ext )
        str = [str ext];
    end

end
