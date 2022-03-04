function y = is64bits()
%
% Use maxArraySize to determine integer width in current Matlab.
%
% See also: dk.env.is32bits

    [~,maxArraySize] = computer();
    y  = maxArraySize > pow2(31);
    
end