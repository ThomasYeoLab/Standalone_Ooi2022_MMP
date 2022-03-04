function x = swap( x, i, j )
%
% x = ant.mat.swap( x, i, j )
%
% Swap elements in x:
%
%   cell / array: i and j should be indices (possibly vectors).
%   struct-array: if i and j are numeric, the corresponding array-elements are swapped
%   struct / struct-array: if i and j are strings, the corresponding FIELDS are swapped
%
% JH

    if isstruct(x) && ischar(i)
        n = numel(x);
        for k = 1:n
            tmp = x(k).(j);
            x(k).(j) = x(k).(i);
            x(k).(i) = tmp;
        end
    else
        tmp  = x(j);
        x(j) = x(i);
        x(i) = tmp;
    end
    
end