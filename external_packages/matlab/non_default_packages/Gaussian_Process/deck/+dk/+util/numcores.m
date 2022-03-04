function n = numcores()
%
% n = dk.util.numcores()
%
% Undocumented Matlab feature to get the number of cores on the host.
%
% JH

    n = feature('numCores');
    
    %import java.lang.*;
    %r = Runtime.getRuntime;
    %n = r.availableProcessors;
    
end