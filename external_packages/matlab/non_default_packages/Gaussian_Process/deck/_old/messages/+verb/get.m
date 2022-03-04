function [v,n] = get( quiet )
%
% [v,n] = dk.verb.get( quiet )
%
% If called with a string, returns the corresponding verbosity code.
% If called with true/false, using input as quiet flag.
%
% JH

    if nargin == 0
        quiet = false;
    end
    dat = dk.verb.data;

    if ischar(quiet)
        n = lower(quiet);
        [~,v] = ismember( n, dat.levels );
    else
        % read environment variable
        v = deblank(getenv(dat.name));
        if isempty(v)
            v = dk.verb.set(dat.default,true);
        else
            v = str2double(v);
        end
        n = dat.levels{v};

        % show message
        if ~quiet
            dk.println( '[dk.verb] Currently set to "%s".', n );
        end
    end
    
end