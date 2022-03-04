function m = mad( x, dim )
%
% Median absolute deviation.
% See: https://en.wikipedia.org/wiki/Median_absolute_deviation
%

    m = nanmedian(abs(bsxfun( @minus, x, nanmedian(x,dim) )),dim);

end