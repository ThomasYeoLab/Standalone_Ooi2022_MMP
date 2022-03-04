function y = rgb( c, n )
%
% y = dk.is.rgb( c, n=0 )
%
% Checks input is a valid RGB matrix.
% Optionally check number of rows.
%
% JH

    if nargin < 2, n=0; end

    y = ismatrix(c) && isnumeric(c) && ...
        (numel(c)==3 || size(c,2)==3) && all(dk.num.between( c(:), 0, 1 ));
    
    if n > 0
        y = y && size(c,1)==n;
    end

end
