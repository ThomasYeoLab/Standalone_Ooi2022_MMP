function [h,l] = gridfit( nelem, lhratio )
%
% [h,l] = dk.gridfit( nelem, lhratio=16/9 )
%
% Return optimal grid size to fit nelem elements with ratio lhratio (default: 16/9).
% Common ratios are:
%
%   5:4, 4:3        slides
%   16:9, 16:10     widescreen
%   (1+sqrt(5))/2   golden
%   297/210         a4 (landscape)
%   420/297         a3 (landscape)
%
% JH

    % use 16:9 by default
    if nargin < 2
        lhratio = 16/9;
    end
    if ischar(lhratio)
    switch lower(lhratio)
        case 'slide'
            lhratio = 4/3;
        case 'wide'
            lhratio = 16/9;
        case 'golden'
            lhratio = (1+sqrt(5))/2;
        case 'a4'
            lhratio = 297/210;
        case 'a3'
            lhratio = 420/297;
        otherwise
            error( 'Unknown ratio: %s', lhratio );
    end
    end
    
    % solve system
    %
    %   l/h = lhratio
    %   h*l >= nelem
    %
    h = ceil(sqrt( nelem / lhratio ));
    l = ceil(nelem / h);
    %l = fix(h*lhratio);
    
end