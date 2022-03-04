function [n,folder] = save( slices, folder, pattern )
%
% [n,folder] = ant.img.save( slices, folder, pattern )
%
% Save a bunch of stacked images individually into a directory.
% By default, a directory is created on the Desktop.
% The pattern can be used to specify image format.
%
% The command returns the number of images saved, and the folder in which they were saved.
%
% JH

    if nargin < 2, folder = fullfile(dk.env.desktop,dk.fs.tempname); end
    if nargin < 3, pattern = 'img_%d.png'; end

    if ~dk.fs.isdir(folder)
        dk.assert( mkdir(folder), 'Could not create folder "%s".', folder );
    end
    
    slices = ant.img.vol2slices(slices);
    n = numel(slices);

    dk.print('[dk.util.save_slices] Saving %d images in folder "%s"...',n,folder);
    for i = 1:n
        imwrite( slices{i}, sprintf(fullfile(folder,pattern),i) );
    end
    
end
