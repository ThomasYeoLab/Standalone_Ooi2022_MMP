function stable = filter_check_stability( a )
%
% a should be the denominator polynomial (eg second output of butter or fir1).
% This function checks if all the poles (roots of the denominator) lie strictly within the unit ball.

    stable = all(abs(roots(a)) < 1);

end
