function vol2gif( filename, volume, delay, resize )
%
% VOL2GIF( filename, volume, delay=100ms, resize=[] )
%
% Create animated GIF from 3D matrix and save as given filename.
% Default delay is 0.1 sec.
% 
% JH

    dk.assert( dk.env.require('convert'), [ ...
        'This utility requires imagemagick to be installed on the host system.\n' ...
        'It is available on OSX through homebrew, and on Linux through package managers.' ...
    ] );

    if nargin < 3, delay = 100; end
    if nargin < 4, resize = []; end
    
    % make sure it has the correct extension
    filename = dk.str.xset(filename,'gif');
    
    % convert delay to suitable unit
    delay = delay/10;
    
    % load slices
    if ischar(volume)
        volume = ant.img.load( volume );
    end
    volume = ant.img.vol2slices( volume ); % make sure it is a cell
    nslices = numel(volume);
    
    % resize if required
    if ~isempty(resize)
        for i = 1:nslices
            volume{i} = imresize( volume{i}, resize, 'bilinear' );
        end
    end
    
    % export to temporary folder
    folder  = fullfile( tempdir, dk.fs.tempname );
    pattern = sprintf('img_%%0%dd.png',1 + floor(log10(nslices)));
    ant.img.save( volume, folder, pattern );
    
    [s,m] = system(sprintf( 'convert -delay %d -loop 0 %s %s', delay, fullfile(folder,'img_*.png'), filename ));
    dk.reject( s, 'Could not run convert command:\n%s.', m );
    
end
