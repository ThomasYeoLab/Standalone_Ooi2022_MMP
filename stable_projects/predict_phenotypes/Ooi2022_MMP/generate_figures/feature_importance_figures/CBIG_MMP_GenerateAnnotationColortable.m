function colortable = CBIG_MMP_GenerateAnnotationColortable(discretization_res, colorscale)

% colortable = CBIG_MMP_GenerateAnnotationColortable(discretization_res, colorscale)
% 
% Adapted from CBIG_TRBPC_GenerateAnnotationColortable.
% Generate a colortable for surface annotation based on an input colorscale
%
% Input:
%   - discretization_res: number of distinct discrete colors in the output colortable
%   - colorscale        : the input color scheme that the output colortable for the annotation is produced
% Output:
%   - colortable        : the output colortable for surface annotation.
%                         The underlying gray color of the brain surface
%                         is saved at the end of the table.
%                         See `write_annotation.m` for the format of the
%                         colortable
%
% Example:
%  colortable = CBIG_TRBPC_GenerateAnnotationColortable(28, colorscale)
%  Discretize the values in colorscale into 28 levels. The resulting 28
%  colors are saved in FreeSurfer colortable's format
%
% Written by Ruby, Gia H. Ngo and CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md

% gray color of the underlaying brain
gray_rgb = [5 5 5];
gray_rgb_sum = 5 + 5*2^8 + 5*2^16;
underlay_color = [gray_rgb 0 gray_rgb_sum];

% fill all structure names as unknown
colortable.numEntries = discretization_res+1;
colortable.orig_tab = '';
colortable.struct_names = cell(discretization_res+1, 1);
for i = 1:discretization_res+1
    colortable.struct_names{i} = 'unknown';
end

% fill in the colors
table = zeros(discretization_res+1, 5);
for i = 1:discretization_res
    table(i, 1:3) = uint8(colorscale(i, :) * 255 + 0.5);
    table(i, 5)   = table(i, 1) + table(i, 2) * 2^8 + table(i, 3) *2^16;
end
table(discretization_res+1, :) = underlay_color;
colortable.table = table;