function x = enumerate( varargin )
%
% x = enumerate( varargin )
%
% Enumerate all possible vectors combining elements from different lists in input.
% 
% JH

    y = dk.mapfun( @(L) 1:numel(L), varargin, false );
    [y{:}] = ndgrid(y{:});

    n = nargin;
    m = numel(y{1});
    x = zeros(m,n);
    for i = 1:n
        x(:,i) = varargin{i}(y{i}(:));
    end
    
end