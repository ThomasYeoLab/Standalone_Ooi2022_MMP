function x = dirichlet( a, n )
%
%  x = ant.math.dirichlet( a, n )
%
% Sample from a Dirichlet distribution with parameters a (vector).
% The number of elements in a determines the dimensionality.
% n is the number of samples.
%
% If all elements in a are 1, then output weights sample a simplex uniformly.
% If ai < 1, then samples are "pushed away" from point i.
% If all ai > 1, then samples concentrate near the centre.
%
% See: 
%   https://en.wikipedia.org/wiki/Dirichlet_distribution#Gamma_distribution
%   https://stats.stackexchange.com/a/244946/44129
%
% JH

    a = a(:)';
    d = length(a);
    x = gamrnd( repmat(a,n,1), 1, n, d );
    x = bsxfun( @rdivide, x, sum(x,2) );

end
