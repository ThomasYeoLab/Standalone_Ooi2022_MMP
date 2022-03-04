function p = pairelm( x, step )
%
% p = ant.mat.pairelm( x, step=1 )
%
%   Return consecutive pairs of elements in input array, separated by specified step.
%   
% EXAMPLE
% -------
%
%   ant.mat.pairelm( 1:5, 2 )
%       { [1,3], [2,4], [3,5] }
%
% JH

    if nargin < 2, step=1; end
    
    n = numel(x)-step;
    p = cell(1,n);
    for i = 1:n
        p{i} = [x(i), x(i+step)];
    end

end