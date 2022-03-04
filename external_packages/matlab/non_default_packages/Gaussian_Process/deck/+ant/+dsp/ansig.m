function [env,phi,frq] = ansig( ts )
%
% [env,phi,frq] = ansig( ts )
% 
% Compute analytic signal from input TimeSeries instance.
% The input ts should be arithmetically sampled.
% Outputs are three time-series.
%
% JH

    if nargout <= 2
        [env,phi] = ant.ts.ansig( ts.vals, ts.fs(true) );
        env = ant.TimeSeries( ts.time, dk.bsx.add(env,ts.mean) );
        phi = ant.TimeSeries( ts.time, phi );
    else
        [env,phi,frq] = ant.ts.ansig( ts.vals, ts.fs(true) );
        env = ant.TimeSeries( ts.time, dk.bsx.add(env,ts.mean) );
        phi = ant.TimeSeries( ts.time, phi );
        frq = ant.TimeSeries( ts.time, frq );
    end

end
