function CreateFreeSurferColormap

n = 101;
remove_index = [3 7 11:12 14 19 20:28 31 33 35:58 61:68 70:79];
remove_bool = ones(n+length(remove_index), 1);
remove_bool(remove_index) = 0;

load freesurfer_color.txt
[B, I] = unique(freesurfer_color, 'rows', 'first');
freesurfer_color = freesurfer_color(sort(I, 'ascend'), :);
freesurfer_color = freesurfer_color/255;
freesurfer_color = freesurfer_color(1:length(remove_bool), :);

freesurfer_color = freesurfer_color(logical(remove_bool), :);

% Replace freesurfer_color
freesurfer_color(11, :) = [119 140 176]/255;
freesurfer_color(12, :) = [255 0 0]/255;
freesurfer_color(13, :) = [255 152 213]/255;
freesurfer_color(17, :) = [255 255 0]/255;
freesurfer_color(18, :) = [0 0 130]/255;

% write colortable for matlab
save('freesurfer_color.mat', 'freesurfer_color');

% write colortable for freesurfer
fid = fopen('MyColorLUT.txt', 'w');
for i = 1:size(freesurfer_color, 1)
     fprintf(fid, '%3d %15s %3d %3d %3d   0\n', i-1, ['NONAME' num2str(i-1)], freesurfer_color(i, 1)*255, freesurfer_color(i, 2)*255, freesurfer_color(i, 3)*255);
end
fclose(fid);
