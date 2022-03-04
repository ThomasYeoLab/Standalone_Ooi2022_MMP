function CBIG_SmoothPaintFile(paint_file, output_paint_file, coord_file, topo_file, background_val, iter)

% CBIG_SmoothPaintFile(paint_file, output_paint_file, coord_file, topo_file, background_val, iter)
%
% This function is used to Smooth paint, but background_val (e.g.
% FreeSurferMedialWall) has to stay the same.
% 
% Input:
%      -paint_file:
%       input paint file. e.g. 'path_to_paint_file/lh.something.paint'
%       
%      -output_paint_file:
%       output smoothed paint file. e.g. 
%       'path_to_smoothed_paint_file/lh.smoothed.paint'
%      
%      -coord_file: 
%       caret coordinate file. e.g. 'path_to_coord_file/xxx.coord'
% 
%      -topo_file:
%       caret topological file. e.g. 'path_to_topo_file/xxx.topo'
%
%      -background_val:
%       value of the background (e.g. FreeSurferMedialWall), default is 1
%       
%      -iter:
%       number of iterations in smoothing, default is 5.
%      
% Output:
%      -mesh: 
%       a mesh structure where coord_file corresponds to the field 'vertices'.
%       topo_file corresponds to the field 'faces'.
%
% Example:
% CBIG_SmoothPaintFile('path_to_paint_file/lh.something.paint', 'path_to_smoothed_paint_file/lh.smoothed.paint','path/Human.PALS_B12.LEFT_AVG_B1-12.INFLATED.clean.73730.coord', 'path/Human.sphere_6.LEFT_HEM.73730.topo', 1, 5)
%
% Written by CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md


if(nargin < 5)
   background_val = 1; 
end

if(nargin < 6)
   iter = 5;
end

paint = caret_load(paint_file);
mesh = CBIG_ConvertCaretSurfaces2MyFormat(coord_file, topo_file);

if(size(paint.data, 2) > 1)
   error('Only working with paint file with one paint'); 
end

% convert paint files into binary matrix
disp('Converting paint to binary matrix');
orig_paint = unique(paint.data);
mapping = 1:length(orig_paint);

reordered_paint = zeros(size(paint.data, 1), 1);
for i = 1:length(orig_paint)
   reordered_paint(paint.data == orig_paint(i)) = i;  
end

bin_paint = zeros(length(mapping), size(paint.data, 1));
index = sub2ind(size(bin_paint), reordered_paint', 1:size(bin_paint, 2));
bin_paint(index) = 1;

% Smooth Matrix
disp('Smoothing')
bin_paint = MARS_AverageData(mesh, single(bin_paint), 0, iter);

% Grab smoothed paint
disp('Computing Smooth Labels');
[Y, new_paint] = max(bin_paint, [], 1);

unsmoothed_paint = paint.data;
for i = mapping
   paint.data(new_paint == i) = orig_paint(i);
end
paint.data(unsmoothed_paint == background_val) = background_val;

% save
disp('Writing out')
caret_savepaint(output_paint_file, paint)

