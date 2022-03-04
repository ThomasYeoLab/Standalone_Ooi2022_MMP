function x = nanreplace( x, val )
%
% x = nanreplace( x, val=0 )
%
% Replace all NaNs with specified value.
%
% JH

    if nargin < 2, val = 0; end
    x(isnan(x)) = val;

end