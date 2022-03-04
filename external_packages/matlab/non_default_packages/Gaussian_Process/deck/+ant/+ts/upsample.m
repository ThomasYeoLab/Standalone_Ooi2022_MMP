function [y, ty] = upsample( x, tx, fs, method )
%
% [y,ty] = ant.ts.upsample( x, tx, fs, method=pchip )
%
% Upsample a time-series using interpolation.
%
% JH
    
    if nargin < 4, method = 'pchip'; end
    
    [x,tx] = dk.formatmv(x,tx,'vertical');
    
    % check that fs is greater than current sampling rate
    dt = mean(diff(tx));
    newdt = 1/fs;
    assert( newdt <= dt, 'Requested sampling rate is lower than current one, use ant.ts.downsample instead.' );
    
    % interpolate
    ty = transpose( tx(1) : newdt : tx(end) );
    y  = interp1( tx, x, ty, method );
    
end
