function d = digits( x, b )
%
% d = digits(x,b)
%
% Compute the digits of integers x in base b.
%
% JH

    assert( all(fix(x)==abs(x)), 'Bad numbers.' );
    assert( isscalar(b) && fix(b)==abs(b) && b > 0, 'Invalid base.' );

    n = numel(x);
    L = 1 + fix( log(max(x,1)) / log(b) ); % number of digits for each number
    L = max(L); % max number of digits needed
    
    d = zeros(n,L);
    for i = 1:L
        d(:,L-i+1) = rem(x,b);
        x = fix(x/b);
    end
    
end