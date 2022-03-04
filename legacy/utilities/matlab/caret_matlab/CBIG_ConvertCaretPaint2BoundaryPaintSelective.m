function CBIG_ConvertCaretPaint2BoundaryPaintSelective(paint_file, output_paint_file, coord_file, topo_file, boundary_index, exclusion_indices, selection_mat)

% CBIG_ConvertCaretPaint2BoundaryPaint(paint_file, output_paint_file, coord_file, topo_file, boundary_index, exclusion_indices, selection_mat)
% 
% Regions in the exclusion index are excluded (e.g., "1" might specify FreeSurferDefinedMedialWall)
% 
% Set boundary vertices to values specified by boundary_index. If boundary
% index is negative, then set to original paint color
% 
% non-boundary vertices are always set to 0 (background)
%
% selection_mat is a binary K x K matrix, where K is the maximum value in the
% paint_file
% 
% if selection_mat(i, j) = 1, then we set a vertex to be a boundary 
% boundary vertex if it has value i and one of its neighbors has value j.
% For example, if selection_mat = 
%
%  [0 1 1]
%  [0 0 1]
%  [0 0 0]
%
% then only vertices whose value = 1 and neighbors are either 2 or 3 are
% set to boundary values as well as vertices whose values = 2 and neighbors
% = 3 are set to boundary values.
%
% 
% example usage: 
%       CBIG_ConvertCaretPaint2BoundaryPaint('lh.something.paint', 'lh.out.paint', 'Human.PALS_B12.LEFT_AVG_B1-12.INFLATED.clean.73730.coord', 'Human.sphere_6.LEFT_HEM.73730.topo', -1, 1);
%
%       Assuming that lh.something.paint is from CBIG_WriteMatlabLabelsToCaretPaint, then here we are setting boundaries
%       vertices to be same values as it's original component's values and excluding FreeSurfer Medial wall vertices
%
%       CBIG_ConvertCaretPaint2BoundaryPaint('lh.something.paint', 'lh.out.paint', 'Human.PALS_B12.LEFT_AVG_B1-12.INFLATED.clean.73730.coord', 'Human.sphere_6.LEFT_HEM.73730.topo', 1, 1);
% 
%       Assuming that lh.something.paint is from CBIG_WriteMatlabLabelsToCaretPaint, then here we are setting boundaries
%       vertices to be FreeSurfer Medial wall and excluding FreeSurfer Medial wall vertices
%
% Written by CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md


if(ischar(boundary_index))
   boundary_index = str2num(boundary_index); 
end

if(ischar(exclusion_indices))
   exclusion_indices = str2num(exclusion_indices); 
end

if(length(boundary_index) > 1)
   error('boundary index should only be of length 1'); 
end

paint = caret_load(paint_file);
mesh = CBIG_ConvertCaretSurfaces2MyFormat(coord_file, topo_file);

disp(['Excluded labels: ' paint.paintnames{exclusion_indices+1}]);
if(boundary_index < 0)
   disp('Setting boundary vertices to original paint values'); 
else
   disp(['Setting boundary vertices to same values as ' paint.paintnames{boundary_index+1}]); 
end

new_data = paint.data;
tic
for i = 1:size(new_data, 1)
    if(mod(i, 10000) == 1)
        toc
        disp(num2str(i));
        tic
    end
    neighbors = mesh.vertexNbors(:, i);
    neighbors = neighbors(neighbors ~= 0);
    for j = 1:size(new_data, 2)
        curr_paint = paint.data(i, j);
        
        if(isempty(find(exclusion_indices == curr_paint, 1))) % not in exclusion indices
        
            accepted_neighbors = find(selection_mat(curr_paint, :) == 1);
            if(~isempty(accepted_neighbors))
                
                neighbors_paint = unique(paint.data(neighbors, j));
                if(isempty(setdiff(neighbors_paint, [curr_paint; exclusion_indices])))
                    % is interior
                    new_data(i, j) = 0;
                elseif(isempty(intersect(neighbors_paint, accepted_neighbors)))
                    % boundary vertex, but vertex and it's neighbors not in
                    % selection_mat
                    new_data(i, j) = 0;
                else
                    % is boundary
                    if(boundary_index < 0)
                        new_data(i, j) = curr_paint; % same as before
                    else
                        new_data(i, j) = boundary_index;
                    end
                end
            else
                new_data(i, j) = 0;
            end
        end
    end
end

paint.data = new_data;
caret_savepaint(output_paint_file, paint)

