function CBIG_DrawAndSaveSurfFunction(mesh_name, parcellation_matlab_file, min_threshold, max_threshold, neg_flag, exit_flag)

% CBIG_DrawAndSaveSurfFunction(mesh_name, parcellation_matlab_file, min_threshold, max_threshold, neg_flag, exit_flag)
%
% This function is used to draw a parcellation with threshold. If
% neg_flag = '1', the threshold will be [min_threshold,max_threshold] and 
% [-max_threshold,-min_threshold]; If neg_flag = '0', the threshold will be 
% [min_threshold,max_threshold].
%
% Input:
%      -mesh_name: 
%       mesh structure, e.g. 'fsaverage5'
%
%      -parcellation_matlab_file:
%       a .mat file which contains two Nx1 vector 'lh_data' and 'rh_data',
%       where N is equal to the number of vertices of mesh_name
%
%      -min_threshold, max_threshold: (input should be string)
%       threshold values which is used to threshold the data in
%       parcellation_file. 
%
%      -neg_flag: 
%       If neg_flag = '1', negative threshold will be performed. Otherwise 
%       only [min_threshold,max_threshold] will be performed.
%
%      -exit_flag: 
%       if exit_flag = 0, matlab won't exit after finish. This exit_flag 
%       should be double not string. 
%                       
% Example: 
% CBIG_DrawAndSaveSurfFunction('fsaverage5', 'path/test.mat', '0.3','0.6', '0',0 )
%
% Written by CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md


if(nargin < 1)
  display('Example usage: CBIG_DrawAndSaveSurfFunction fsaverage5 parcellation_file 1');
end

if(ischar(min_threshold))
   min_threshold = str2num(min_threshold); 
end

if(ischar(max_threshold))
   max_threshold = str2num(max_threshold); 
end

if(ischar(neg_flag))
   neg_flag = str2num(neg_flag); 
end

load(parcellation_matlab_file);

figure; set(gcf, 'renderer', 'zbuffer'); hold on;
for hemi = {'lh' 'rh'}
    avg_mesh = CBIG_ReadNCAvgMesh(hemi{1}, mesh_name, 'inflated');
    if(strcmp(hemi{1}, 'lh'))
        data = lh_data;
    else
        data = rh_data;
    end
    
    if(neg_flag == 1)
        data(data > max_threshold) = max_threshold;
        data(data < -max_threshold) = -max_threshold;
        
        data(data < min_threshold & data > 0) = 0;
        data(data > -min_threshold & data < 0) = 0;
        
        data(1) = -max_threshold;
        data(12) = max_threshold;
    else
        data(data < min_threshold) = 0;
        data(data > max_threshold) = max_threshold;

        data(1) = 0;
        data(12) = max_threshold;
    end
    
    for i = 1:2
        if(strcmp(hemi{1}, 'lh'))
            if(i == 1)
                subplot(2, 2, 1);
            else
                subplot(2, 2, 3);                
            end
            s_handle = TrisurfMeshData(avg_mesh, data); shading interp; axis off
            set(s_handle, 'DiffuseStrength', 1);
            set(s_handle, 'SpecularStrength', 0);
            if(i == 1)
                view(-90, 30); subplot(2, 2, 1); zoom(1.2); title(['Left lateral']);
            else
                view(90, -20); subplot(2, 2, 3); zoom(1.2); title('Left medial');
            end
        else
            if(i == 1)
                subplot(2, 2, 2);
            else
                subplot(2, 2, 4);                
            end
            s_handle = TrisurfMeshData(avg_mesh, data); shading interp; axis off
            set(s_handle, 'DiffuseStrength', 1);
            set(s_handle, 'SpecularStrength', 0);
            if(i == 1)
                view(100, 10); subplot(2, 2, 2); zoom(1.6); title(['Right lateral:']);
            else
                view(-100, -20); subplot(2, 2, 4); zoom(1.3); title('Right medial');
            end
        end
    end
end
colorbar

z = strfind(parcellation_matlab_file, '.mat');
parcellation_matlab_file = parcellation_matlab_file(1:z-1);
saveas(gcf, [parcellation_matlab_file '.tif'], 'tif');



if(exit_flag)
  exit
end
