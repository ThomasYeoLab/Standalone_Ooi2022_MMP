function CBIG_CombinePaintFiles(paint_file_list, output_paint_file)

% CBIG_CombinePaintFiles(paint_file_list, output_paint_file)
%
% paint_file_list = text file, where each line corresponds to the full path to a paint file.
% output_paint_file = combined paint file is saved into output_paint_file
% 
% For each vertex, take on the value of the first non-zero paint value,
% i.e., first paint file in paint_file_list has precedence over second paint file etc.
%
% Note that if the paint files in the paint_file_list have different
% paintnames, the paintnames of the first file is inherited. 
%
% Written by CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md


% read paint files
fid = fopen(paint_file_list, 'r');
paint_files = textscan(fid, '%s');
paint_files = paint_files{1};
fclose(fid);

% paint cell
paint_cell = cell(length(paint_files), 1);
for i = 1:length(paint_files)
   paint_cell{i} = caret_load(paint_files{i});
end

% check paint data all the same size!!
paint = paint_cell{1};
for i = 2:length(paint_cell)
   if(numel(paint.data) ~= numel(paint_cell{i}.data)) 
      error([num2str(i) 'th paintfile does not have same dimension as first paint file']); 
   end
end

% combine
paint = paint_cell{1};
for i = 2:length(paint_cell)
   zero_index = find(paint.data == 0);
   paint.data(zero_index) = paint_cell{i}.data(zero_index); 
end

% check
if((max(paint.data(:) + 1) > length(paint.paintnames)))
   error('After combining, there are now more regions than there are paintnames!'); 
end

% save
caret_savepaint(output_paint_file, paint)
