function CBIG_DrawAndSaveSurfParcellation(mesh_name, parcellation_matlab_file, exit_flag)

% CBIG_DrawAndSaveSurfParcellation(mesh_name, parcellation_matlab_file, exit_flag)
%
% This function is used to draw a parcellation. 
%
% Input:
%      -mesh_name: 
%       mesh structure, e.g. 'fsaverage5'
%
%      -parcellation_matlab_file:
%       a .mat file which contains two Nx1 vector 'lh_data' and 'rh_data',
%       where N is equal to the number of vertices of mesh_name
%
%      -exit_flag: 
%       if exit_flag = 0, matlab won't exit after finish. This exit_flag 
%       should be double not string. 
%                       
% Example: 
% CBIG_DrawAndSaveSurfParcellation('fsaverage5', 'path/test.mat', 0 )
%
% Written by CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md


if(nargin < 1)
  display('Example usage: CBIG_DrawAndSaveSurfParcellation fsaverage5 parcellation_file 1');
end

if(ischar(exit_flag))
   exit_flag = str2num(exit_flag); 
end

load(parcellation_matlab_file);
load freesurfer_color.mat;

figure; set(gcf, 'renderer', 'zbuffer'); hold on;
for hemi = {'lh' 'rh'}
    avg_mesh = CBIG_ReadNCAvgMesh(hemi{1}, mesh_name, 'inflated');
    if(strcmp(hemi{1}, 'lh'))
        labels = lh_labels;
    else
        labels = rh_labels;
    end
    labels(12) = 100;
    
    for i = 1:2
        if(strcmp(hemi{1}, 'lh'))
            if(i == 1)
                subplot(2, 2, 1);
            else
                subplot(2, 2, 3);                
            end
            s_handle = TrisurfMeshData(avg_mesh, labels); shading flat; axis off
            set(s_handle, 'DiffuseStrength', 1);
            set(s_handle, 'SpecularStrength', 0);
            colormap(freesurfer_color);
            if(i == 1)
                view(-90, 30); subplot(2, 2, 1); zoom(1.2); 
            else
                view(90, -20); subplot(2, 2, 3); zoom(1.2); 
            end
        else
            if(i == 1)
                subplot(2, 2, 2);
            else
                subplot(2, 2, 4);                
            end
            s_handle = TrisurfMeshData(avg_mesh, labels); shading flat; axis off
            set(s_handle, 'DiffuseStrength', 1);
            set(s_handle, 'SpecularStrength', 0);
            colormap(freesurfer_color);
            if(i == 1)
                view(100, 10); subplot(2, 2, 2); zoom(1.6); 
            else
                view(-100, -20); subplot(2, 2, 4); zoom(1.3); 
            end
        end
    end
end

z = strfind(parcellation_matlab_file, '.mat');
parcellation_matlab_file = parcellation_matlab_file(1:z-1);
saveas(gcf, [parcellation_matlab_file '.tif'], 'tif');



if(exit_flag)
  exit
end
