function ts = randu(ns,tlen,fs,lo,up)
%
% ts = ant.dsp.mk.randu(ns,tlen,fs,lo=0,up=1)
%
% Generate random time-series with uniformly distributed values.
%

    if nargin < 5, up=1; end
    if nargin < 4, lo=0; end
    
    if isscalar(up), up = up*ones(1,ns); end
    if isscalar(lo), lo = lo*ones(1,ns); end
    
    t = 0 : (1/fs) : tlen;
    nt = numel(t);
    
    v = dk.bsx.mul( rand( nt, ns ), up-lo );
    v = dk.bsx.add( v, lo );
    
    ts = ant.TimeSeries(t,v);    

end
