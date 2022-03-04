function n = msdeq(a,b)
%
% n = dk.num.msdeq(a,b)
%
% Compare the number of digits between max(a,b) and abs(a-b).
% Large values indicate that both numbers are close, whereas
% small values indicate _relatively_ large differences.
%
% The output value is always a non-negative integer, and the
% maximal value is obtained for msd(a,a) == Inf.
%
% This is useful to measure the "similarity" between numbers
% based on their most significant digits, eg:
%
%   1 ./(1 + exp( -dk.num.msd(a,b)/n ))
%
% gives a similarity score between 0 and 1 with variations
% scaled to the equality of n digits.
%
% JH

    n = floor(log10(max(a,b))) - floor(log10(abs( a-b )));
    
end