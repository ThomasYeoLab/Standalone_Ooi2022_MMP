function y = startswith(s,p,c)
%
% ans = dk.str.startswith( str, prefix, case_sensitive=true )
%
% Checks whether the beginning of string str matches given prefix.
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
        y = strcmp(s(1:m), p);
    else
        y = strcmpi(s(1:m), p);
    end

end