function s = recspace(a,b,n)
%
% Sample n reciprocally spaced points between a and b.
% Note: a and b MUST be positive.

    assert( isscalar(a) && isscalar(b) && a > eps && b > eps, 'a and b must be positive scalars.' );
    s = 1 ./ linspace( 1/a, 1/b, n );

end
