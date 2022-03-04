function y = empty(varargin)
%
% y = empty(x)
% y = empty( x1, x2, ... )
%
% Check if input(s) is/are empty.
% Behaves intuitively with structs.
%

    y = dk.mapfun( @do_test, varargin, true );
end

function y = do_test(x)
    if isstruct(x)
        y = isempty(fieldnames(x));
    else
        y = isempty(x);
    end
end