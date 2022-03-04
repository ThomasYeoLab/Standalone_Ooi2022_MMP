function ok = require( name )
%
% ok = dk.env.require( name )
%
% Require application to be installed on the system.
% This shorthand is mainly to get rid of the output printed "system" if it is called with only one output.
%
% JH

    [s,m] = system( ['which ' name] );
    ok = ~logical(s);
    
end
