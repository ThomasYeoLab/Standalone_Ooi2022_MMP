function [u,c] = countunique(x)
%
% [u,c] = dk.countunique(x)
%
% Count unique occurrences of elements in matrix x.
% u and c are column vectors of the same size, where:
%   u(i)    i^th unique value
%   c(i)    corresponding count
%
% JH

    [u,~,c] = unique(x(:));
    c = accumarray(c(:),1);

end