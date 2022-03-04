function y = is32bits()
%
% Use maxArraySize to determine integer width in current Matlab.
%
% See also: dk.env.is64bits

    y = ~dk.env.is64bits();
    
end