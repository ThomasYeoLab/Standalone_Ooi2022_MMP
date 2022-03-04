function show( cmap, sz )
%
% dk.cmap.show( cmap, sz=[600 100] )
%
% This function is used to visualise colormaps, given as Nx3 RGB matrices.
% Input matrix is resized(using nearest-neighbour interpolation), and displayed 
% in gcf, using imshow.
%
% JH

    if nargin < 2, sz=[600 100]; end
    
    cmap = flipud(reshape( cmap, [],1,3 ));
    if sz(2) > sz(1)
        cmap = cmap';
    end
    
    imshow(imresize(cmap,sz,'nearest'));

end