function [x,y,img] = resample( x, y, img, method, thr, prc )
%
% [x,y,img] = ant.img.resample( x, y, img, method=cubic, thr=1e-3, prc=50 )
%
% Interpolate localised image data onto an equivalent cartesian grid, 
% if x and y are not arithmetically sampled.
%
% The image data is defined by the triplet {x,y,img}, where:
%       x corresponds to the horizontal, and 
%       y corresponds to the vertical (from the top left corner).
%
% The method is one of the valid option to interp2.
%
% thr controls the stringence of how "regularly" x and y should be sampled.
% If the relative variation (std(dx)/mean(dx) with dx=diff(x)) is larger than thr, 
% then interpolation is triggered, and the new selected step is prctile(dx,prc).
%
% JH

    if nargin < 6, prc = 50; end
    if nargin < 5, thr = 1e-3; end
    if nargin < 4, method = 'cubic'; end

    % process x and y
    x = x(:)'; dx = diff(x); nx = numel(x);
    y = y(:)'; dy = diff(y); ny = numel(y);
    assert( all(dx > eps) && all(dy > eps), 'x and y must be increasing.' );
    
    % transpose image if needed
    if size(img,1) ~= ny && size(img,2) == ny
        img = transpose(img);
    end
    assert( all( [ny,nx]==size(img) ), 'Size mismatch between inputs.' );
    
    % test relative variation
    rvar = @(z) std(z)/max(eps,mean(z));
    if rvar(dx)>thr || rvar(dy)>thr
        
        dk.info( '[dk.ui.imresample] Triggering resampling due to variable x or y steps.' );
        
        dx = prctile(dx,prc); xnew = x(1):dx:x(end);
        dy = prctile(dy,prc); ynew = y(1):dy:y(end);
        [gxold,gyold] = meshgrid(x,y);
        [gxnew,gynew] = meshgrid(xnew,ynew);
        
        x = xnew;
        y = ynew;
        img = interp2( gxold, gyold, img, gxnew, gynew, method );
        
    end
    
end
