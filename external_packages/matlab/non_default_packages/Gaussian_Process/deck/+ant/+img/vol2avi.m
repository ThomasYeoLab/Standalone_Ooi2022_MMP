function vol2avi( filename, volume, fps, callback )
%
% ant.img.vol2avi( filename, volume, fps=30, callback=dk.forward )
%
% Create video with AVI format from slices of input volume.
% Volume can be a cell of images, or a 3D/4D array of images.
%
% Callback can be specified to optionally process slices before 
% writing to video stream (e.g. to ensure they are RGB images).
%
% See also: ant.img.vol2slices, ant.img.vol2mp4
%
% JH

    if nargin < 3, fps = 30; end
    if nargin < 4, callback = @dk.forward; end
    
    % open movie file
    writer = VideoWriter( dk.str.xset(filename,'avi'), 'Motion JPEG AVI' );
    writer.FrameRate = fps;
    writer.open();
    
    % convert volume to cell of slices
    if ischar(volume)
        volume = ant.img.load( volume );
    end
    volume  = ant.img.vol2slices( volume ); % make sure it is a cell
    nslices = numel(volume);
    
    % write other slices to file
    for i = 1:nslices
        slice = callback( volume{i} );
        writer.writeVideo( slice );
    end

    % close video file
    writer.close();
    
end
