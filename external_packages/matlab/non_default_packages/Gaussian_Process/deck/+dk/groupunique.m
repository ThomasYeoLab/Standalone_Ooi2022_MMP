function [grp,val] = groupunique(x,n)
%
% [grp,val] = groupunique(x)
% [grp,val] = groupunique(x,n)
%
% For each unique element in x, find corresponding group of indices.
% If n is specified, then grp is 1xn, and the last output groups may be empty.
%
% See also: dk.grouplabel
%
% JH

    if nargin < 2, n=[]; end

    [val,~,L] = unique(x(:));
    grp = dk.grouplabel(L,n);
    
end

% If n is positive, then grp is 1xn, and the last output groups may be empty.
% Otherwise the output is compressed to contain only non-empty groups (default).