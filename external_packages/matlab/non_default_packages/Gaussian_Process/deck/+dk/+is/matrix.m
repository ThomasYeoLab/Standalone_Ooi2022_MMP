function y = matrix( x, n )
%
% y = dk.is.matrix( x, n=[] )
%
% Check if input is a numeric matrix.
% Optionally check for size:
% - scalar means square
% - otherwise [row,column] (set =0 for any)
%
% JH

    if nargin < 2, n=[]; end

    y = (isnumeric(x) || islogical(x)) && ismatrix(x);
    
    switch numel(n)
        case 0
            % nothing to do
        case 1
            y = y && all(size(x) == n);
        case 2
            if n(1) > 0, y = y && size(x,1)==n(1); end
            if n(2) > 0, y = y && size(x,2)==n(2); end
        otherwise
            error('Unexpected input.');
    end

end