function n = ld_name( type )
%
% Name of the environment variable for dynamic libraries/runtimes (on UNIX).
% 
% INPUT
%   type        One of {lib,library,run,runtime}.
%
% Contact: jhadida [at] fmrib.ox.ac.uk

    sys = [ isunix(), ismac() ];
    assert( any(sys), 'Windows platforms not supported.' );
    
    % Either libary or runtime path
    switch lower(type)
        case {'lib','library'}
            type = 'LIBRARY';
        case {'run','runtime'}
            type = 'RUN';
        otherwise
            error( 'Unknown linker type "%s"', type );
    end
    
    % OSX and Linux have different prefix
    if all(sys)
        n = ['DYLD_' type '_PATH']; % osx
    else
        n = ['LD_' type '_PATH']; % linux
    end

end
