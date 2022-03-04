function ts = randmvn(ns,tlen,fs,mu,Sigma)
%
% ts = ant.dsp.mk.randmvn(ns,tlen,fs,mu,Sigma)
%
% Generate random time-series with multivariate-random values.
%

    if nargin < 5, Sigma=eye(ns); end
    if nargin < 4, mu=zeros(1,ns); end
    
    t = 0 : (1/fs) : tlen;
    nt = numel(t);
    v = mvnrnd( mu, Sigma, nt );
    
    ts = ant.TimeSeries(t,v);
 
end
