function slices = load( pattern, resize, method )
%
% slices = ant.img.load( pattern, resize=[], method=linear )
%
% Load images matching input pattern, and return in a cell.
% Optionally resize images on the fly.
%
% JH

    if nargin < 2, resize=[]; end
    if nargin < 3, method='linear'; end

    files  = dir(pattern);
    folder = fileparts(pattern);
    nfiles = numel(files);
    slices = cell(1,nfiles);
    dk.print('[dk.util.load_slices] Found %d images to be loaded...',nfiles);

    for i = 1:nfiles
        img = imread(fullfile(folder,files(i).name));
        if ~isempty(resize)
            img = imresize( img, resize, method );
        end
        slices{i} = img;
    end

end
