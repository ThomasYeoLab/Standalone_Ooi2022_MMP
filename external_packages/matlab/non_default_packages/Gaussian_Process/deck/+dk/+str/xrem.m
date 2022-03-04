function [s,r] = xrem( s, n, dotc )
%
% [str,rem] = dk.str.xrem( str, n=inf, dotc='.' )
% [str,rem] = dk.str.xrem( str, 'mat', dotc='.' )
%
% Remove the extension from string.
%
% If n is an integer, it specifies how many extensions should be removed.
% By default n=inf, which means everything after the first dot is removed.
%
% If n is a string, it specifies the extension to be removed, in which case
% the tail of the input string s will be matched against n and removed if
% it matches.
%
% Example:
% >> a = '.aaaaa.aaaa..aaa.aa';
% >> string.rem_ext(a)      % ''
% >> string.rem_ext(a,2)    % '.aaaaa.aaaa.'
% >> string.rem_ext(a,3)    % '.aaaaa.aaaa'
%
% JH

    if nargin < 2, n=inf; end
    if nargin < 3, dotc='.'; end

    r = '';

    if isnumeric(n)

        dots = find(s == dotc);
        n    = min( numel(dots), n );

        if n > 0
            last = dots(end-n+1);
            r = s(last:end);
            s = s(1:last-1);
        end

    else

        if n(1) ~= dotc, n = [dotc n]; end

        l = numel(n);
        if strcmpi( s(end-l+1:end), n )
            r = n;
            s = s(1:end-l);
        end

    end
end
