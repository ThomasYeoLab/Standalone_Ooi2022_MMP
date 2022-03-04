function y = vector( x, n )
%
% y = vector( x )
% y = vector( x, numel )
% y = vector( x, shape )
%
% Check whether input is numeric vector
% Optionally check for:
%  - number of elements 
%  - or shape ('row' or 'col')
%

    y = isnumeric(x) && isvector(x);
    if nargin > 1
        switch n
            case {'row','r','horz'}
                y = y && size(y,1)==1;
            case {'col','c','vert'}
                y = y && size(y,2)==1;
            otherwise
                y = y && numel(x)==n;
        end
    end
    
end