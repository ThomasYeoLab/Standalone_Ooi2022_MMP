function ts = randn(ns,tlen,fs,mu,sigma)
%
% ts = ant.dsp.mk.randn(ns,tlen,fs,mu=0,sigma=1)
%
% Generate random time-series with normally distributed values.
%

    if nargin < 5, sigma=1; end
    if nargin < 4, mu=0; end
    
    if isscalar(sigma), sigma = sigma*ones(1,ns); end
    if isscalar(mu), mu = mu*ones(1,ns); end
    
    t = 0 : (1/fs) : tlen;
    nt = numel(t);
    
    v = dk.bsx.mul( randn( nt, ns ), sigma );
    v = dk.bsx.add( v, mu );
    
    ts = ant.TimeSeries(t,v);

end
