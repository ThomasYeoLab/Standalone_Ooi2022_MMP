function CBIG_DrawAndSaveParcellation(ic_mesh, SUBJECTS_DIR, parcellation_file, exit_flag)

% CBIG_DrawAndSaveParcellation(ic_mesh, SUBJECTS_DIR, parcellation_file, exit_flag)
%
% This function is used to draw a parcellation file. 
%
% Input:
%      -ic_mesh: 
%       mesh structure, e.g. 'fsaverage5'
%
%      -SUBJECTS_DIR: 
%       path to the folder which contains parcellation_file
%
%      -parcellation_file:
%       filename of .nii/.nii.gz files which contain the parcellation 
%       information. SUBJECTS_DIR should contain ['lh.', parcellation_file] 
%       and ['rh.', parcellation_file]
%
%      -exit_flag: 
%       if exit_flag = 0, matlab won't exit after finish. This exit_flag 
%       should be double not string. 
%                       
% Example: 
% CBIG_DrawAndSaveParcellation('fsaverage5', SUBJECTS_DIR, 'test.nii.gz', '0',0 )
%
% Written by CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md


if(nargin < 1)
  display('Example usage: CBIG_DrawAndSaveParcellation fsaverage5 subjects_dir parcellation_file 1');
end

figure; set(gcf, 'renderer', 'zbuffer'); hold on;
final_labels = [];
for hemi = {'lh' 'rh'}
    avg_mesh = CBIG_ReadNCAvgMesh(hemi{1}, ic_mesh, 'inflated');
    x = MRIread([SUBJECTS_DIR '/' hemi{1} '.' parcellation_file]); 
    labels = x.vol(:);
    labels = CBIG_CleanSurfaceParcellation(avg_mesh, labels);

    unique_labels = unique(labels);
    unique_labels = unique_labels(unique_labels~=0);
    final_labels = unique([final_labels unique_labels]);
    
    for i = 1:2
        if(strcmp(hemi{1}, 'lh'))
            subplot(2, 2, i);
            s_handle = TrisurfMeshData(avg_mesh, labels); shading flat; axis off
            set(s_handle, 'DiffuseStrength', 1);
            set(s_handle, 'SpecularStrength', 0);
            if(i == 1)
                view(-90, 30); subplot(2, 2, 1); zoom(1.2); title(['Left lateral: ' num2str(length(unique_labels)) ' labels']);
            else
                view(90, -20); subplot(2, 2, 2); zoom(1.2); title('Left medial');
            end
        else
            subplot(2, 2, 2+i);
            s_handle = TrisurfMeshData(avg_mesh, labels); shading flat; axis off
            set(s_handle, 'DiffuseStrength', 1);
            set(s_handle, 'SpecularStrength', 0);
            if(i == 1)
                view(100, 10); subplot(2, 2, 2+i); zoom(1.5); title(['Right lateral: ' num2str(length(unique_labels)) ' labels, total: ' num2str(length(final_labels)) ]);
            else
                view(-100, -20); subplot(2, 2, 2+i); zoom(1.2); title('Right medial');
            end
        end
    end
end

z = strfind(parcellation_file, 'nii.gz');
parcellation_file = parcellation_file(1:z-1);
saveas(gcf, [SUBJECTS_DIR '/' parcellation_file 'tif'], 'tif');

if(exit_flag)
     exit
end

% permute labels
% perm = randperm(max(labels));
% labels_tmp = labels;
% for i = 1:max(labels_tmp)
%    labels(labels_tmp == i) = perm(i); 
% end
% clear labels_tmp;



