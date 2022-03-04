function [v,n] = set( level, quiet )
%
% [v,n] = dk.verb.set( level, quiet )
%
% level can be string or number, representing verbosity level.
% quiet is logical, defaults to false.
%
% JH

    if nargin < 2, quiet=false; end
    dat = dk.verb.data;

    % parse input
    if ischar(level)
        n = lower(level);
        [~,v] = ismember( n, dat.levels );
    elseif isnumeric(level)
        v = level;
    else
        error('Bad level type.');
    end

    % set environment variable
    try
        n = dat.levels{v};
        setenv( dat.name, num2str(v) );
    catch
        error('Bad level value.');
    end

    % show message
    if ~quiet
        dk.println( '[dk.verb] Setting verbosity to "%s".', n );
    end
    
end