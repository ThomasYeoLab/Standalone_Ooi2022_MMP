function [X,S,L] = mvnrand(ns,nd,ew)
%
% [X,S,L] = ant.stat.mvnrand( ns, nd, ew=0.3 )
%
% Multi-variate normal random generator (random covmat, zero mean).
% The eigen-width determines the "disparity" of eigenvalues, such that:
%   L = 1 + ew*rand(nd,1)
%
% ns: number of samples
% nd: number of dimensions
% ew: eigen-width
%
% X: ns x nd samples
% S: covariance matrix
% L: eigenvalues
%
% JH

    if nargin < 3, ew=0.3; end
    %ew = min(1,max(eps,ew));
    
    Q = orth(randn(nd));
    L = 1 + ew*rand(nd,1);
    S = Q*diag(L)*Q';
    X = randn(ns,nd) * cholcov(S);

end