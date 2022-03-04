function [index,value] = closest( query, data, distfun )
%
% [index,value] = ant.math.closest( query, data, distfun )
%
% Find element in array data which is closest to scalar query.
% By default, the distance function is the absolute difference.
% First output is the index to the closest element, and second
% output its value.
%
% JH

    if nargin < 3, distfun = @(a,b) abs(a(:)-b(:)); end

    [~,index] = min(distfun( data, query ));
    value     = data(index);

end
