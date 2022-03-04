function [mu,sigma,v] = sample_stats( fun, varargin )
%
% [mu,sigma,vals] = ant.math.sample_stats( fun, varargin )
%
%   Robust estimate of mean and std by sampling input function (should return
%   a scalar value at each call).
%
%   The deviation of the sample mean (proportional to 1/\sqrt(N)) is used as an 
%   index of convergence for the sample mean.
%
%
% OPTIONS
% -------
% 
%   init        initial estimates of mu and sigma using this number of calls
%               DEFAULT: 25
%
%   rel         stop sampling if 1/sqrt(n) is below this threshold
%               DEFAULT: 0.05 (+/- 5%)
%
%   abs         stop sampling if sigma/sqrt(n) is below this threshold
%               DEFAULT: 0.05 (1 decimal place)
%
%   maxcall     stop sampling if N exceeds this number of calls
%               DEFAULT: 0 (no limit)
%
%
% JH
    
    % parse inputs
    v = @validateattributes;
    p = inputParser;
    p.FunctionName = 'ant.math.sample_stats';
    
    p.addParameter( 'init', 25, @(x) v(x,{'double'},{'scalar','positive','integer'}) );
    p.addParameter( 'rel', 0.05, @(x) v(x,{'double'},{'scalar','positive'}) );
    p.addParameter( 'abs', 0.05, @(x) v(x,{'double'},{'scalar','positive'}) );
    p.addParameter( 'maxcall', 0, @(x) v(x,{'double'},{'scalar','integer'}) );
    
    p.parse(varargin{:});
    r = p.Results;
    
    % initial sample to estimate deviation of sample mean
    n = r.init;
    if r.maxcall > 0 && n > r.maxcall
        dk.info( 'Initial sample reduced to %d instead of %d.', r.maxcall, n );
        n = r.maxcall;
    end
    
    v = zeros(1,n);
    for i = 1:n
        v(i) = fun();
    end
    
    mu = mean(v);
    sigma = std(v);
    
    % remaining number of calls
    p = max( 1/r.rel, sigma/r.abs );
    p = ceil( p*p );
    if r.maxcall > 0 && p > r.maxcall
        dk.info( 'Remaining sample reduced to %d instead of %d.', r.maxcall-n, p-n );
        p = r.maxcall;
    end
    if p > n
        p = p-n;
    else
        return
    end
    
    % remaining sample
    v(n+p) = nan;
    for i = 1:p
        v(n+i) = fun();
    end
    
    mu = mean(v);
    sigma = std(v);

end