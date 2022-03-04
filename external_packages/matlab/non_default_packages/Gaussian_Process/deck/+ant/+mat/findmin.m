function [sub,val] = findmin(M)
%
% [sub,val] = ant.mat.findmin(M)
%
% Finds subindices of minimum element in array M of arbitrary dimensions.
%
% JH

    [val,k] = min(M(:));

    if isvector(M)
        sub = k;
    else
        sub = cell(1,ndims(M));
        [sub{:}] = ind2sub( size(M), k );
        sub = [sub{:}];
    end
    
end
