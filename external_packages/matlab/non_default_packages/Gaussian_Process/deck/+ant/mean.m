function m = mean(x,d)
%
% m = ant.mean(x,d=1)
%
% Fast mean along specified dimension.
% Note that this does NOT handle NaN values or overflows.
%
% JH

    if nargin < 2, d=1; end
    m = sum(x,d) / size(x,d);

end