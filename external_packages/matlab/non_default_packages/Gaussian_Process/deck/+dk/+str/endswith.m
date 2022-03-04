function y = endswith(s,p,c)
%
% ans = dk.str.endswith( str, suffix, case_sensitive=true )
%
% Checks whether the end of string str matches given suffix.
% By default, the comparison is case-sensitive.
% 
% JH

    assert( ischar(s) && ischar(p), 'Inputs should be strings.' );
    if nargin < 3, c=true; end

    n = numel(s);
    m = numel(p);
    y = false;
    
    if m > n, return; end
    if c
        y = strcmp(s(end-m+1:end), p);
    else
        y = strcmpi(s(end-m+1:end), p);
    end

end