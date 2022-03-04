function [sub,val] = findmax(M)
%
% [sub,val] = ant.mat.findmax(M)
%
% Finds subindices of maximum element in array M of arbitrary dimensions.
%
% JH

    [val,k] = max(M(:));

    if isvector(M)
        sub = k;
    else
        sub = cell(1,ndims(M));
        [sub{:}] = ind2sub( size(M), k );
        sub = [sub{:}];
    end
    
end
