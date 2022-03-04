function [bsize,scale] = bytefmt( b, usym )
%
% [bsize,scale] = dk.util.bytefmt( b, unit_symbol='B' )
%
% Format input bytesize as a struct with conversions to kB, MB, GB and TB.
% If input is in bits, not bytes, set the unit symbol to 'b' instead.
%
% JH

    if nargin < 2, usym='B'; end
    
    units = dk.mapfun( @(x) [x usym], {'','k','M','G','T','P'}, false );
    scale = units{min( numel(units), 1+floor( log(b)/log(1024) ) )};
    
    for i = 1:numel(units)
        u = units{i};
        bsize.(u) = b / 1024^(i-1);
    end
    
    if nargout == 0
        fprintf('%.2f %s\n', bsize.(scale), scale );
    end
    
end
