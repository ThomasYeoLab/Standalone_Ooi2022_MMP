function [yes,dt] = is_arithmetic(t,rtol)
%
% [yes,dt] = ant.priv.is_arithmetic(t,rtol=1e-6)
%
%   Check whether input timecourse is arithmetically sampled (i.e. regular).
%   This is done by comparing maximum and minimum timesteps.
%   Backwards timecourses are supported.
%
% JH

    if nargin < 2, rtol=1e-6; end
    
    % allow backwards timeseries
    dif = diff(t);
    dif = sign(dif(1)) * dif;
    yes = all( dif > eps );
    
    % check regularity
    dt = mean(dif);
    yes = yes && (max(dif) / max(eps,min(dif)) <= 1+rtol);
    
end