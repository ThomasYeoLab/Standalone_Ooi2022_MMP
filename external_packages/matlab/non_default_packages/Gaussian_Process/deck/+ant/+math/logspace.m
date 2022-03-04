function s = logspace(a,b,n)
%
% Sample n logarithmically spaced points between a and b.
% Note: a and b MUST be positive.

    assert( isscalar(a) && isscalar(b) && a > eps && b > eps, 'a and b must be positive scalars.' );
    s = exp(linspace( log(a), log(b), n ));

end
