function CBIG_DrawAndSaveFunction(ic_mesh, SUBJECTS_DIR, parcellation_file, min_threshold, max_threshold, neg_flag, exit_flag)

% CBIG_DrawAndSaveFunction(ic_mesh, SUBJECTS_DIR, parcellation_file, min_threshold, max_threshold, neg_flag, exit_flag)
%
% This function is used to draw a parcellation file with threshold. If
% neg_flag = '1', the threshold will be [min_threshold,max_threshold] and 
% [-max_threshold,-min_threshold]; If neg_flag = '0', the threshold will be 
% [min_threshold,max_threshold].
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
% CBIG_DrawAndSaveFunction('fsaverage5', SUBJECTS_DIR, 'test.nii.gz', '0.3','0.6', '0',0 )
%
% Written by CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md


figure; set(gcf, 'renderer', 'zbuffer'); hold on;
min_threshold = str2num(min_threshold);
max_threshold = str2num(max_threshold);


x1 = MRIread([SUBJECTS_DIR '/lh.' parcellation_file]); 
x2 = MRIread([SUBJECTS_DIR '/rh.' parcellation_file]); 
x1 = x1.vol(:);
x2 = x2.vol(:);

if(str2num(neg_flag) == 1)
    x1(x1 > max_threshold) = max_threshold;
    x2(x2 > max_threshold) = max_threshold;
    x1(x1 < -max_threshold) = -max_threshold;
    x2(x2 < -max_threshold) = -max_threshold;
    
    x1(x1 < min_threshold & x1 > 0) = 0;
    x2(x2 < min_threshold & x2 > 0) = 0;
    x1(x1 > -min_threshold & x1 < 0) = 0;
    x2(x2 > -min_threshold & x2 < 0) = 0;
    
    x1(1) = -max_threshold;
    x1(2) = max_threshold;
    x2(1) = -max_threshold;
    x2(2) = max_threshold;
else
    x1(x1 < min_threshold) = 0;
    x2(x2 < min_threshold) = 0;
    x1(x1 > max_threshold) = max_threshold;
    x2(x2 > max_threshold) = max_threshold;
    
    x1(1) = -max_threshold;
    x1(2) = max_threshold;
    x2(1) = -max_threshold;
    x2(2) = max_threshold;
end



% if(strcmp(threshold, 'znormalize'))
%      mean_val = mean([x1; x2]);
%      std_val = std([x1; x2]);
%      x1 = (x1 - mean_val)./std_val;
%      x2 = (x2 - mean_val)./std_val;
%     
%     minx1 = min(x1);
%     maxx1 = max(x1);
%     minx2 = min(x2);
%     maxx2 = max(x2);
%     
%     min_dev = min([abs(minx1) abs(minx2) abs(maxx1) abs(maxx2)]);
%     
%     x1(x1 < -min_dev) = -min_dev;
%     x2(x2 < -min_dev) = -min_dev;
%     x1(x1 > min_dev) = min_dev;
%     x2(x2 > min_dev) = min_dev;
% end
    
for hemi = {'lh' 'rh'}
    avg_mesh = CBIG_ReadNCAvgMesh(hemi{1}, ic_mesh, 'white');    
    if(strcmp(hemi{1}, 'lh'))
        labels = x1;
    else
        labels = x2;
    end
    
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
            
            view(120,20);
            camlight('headlight', 'infinite');
            view(300,20);
            camlight('headlight', 'infinite');
            if(i == 1)
                view(-90, 30); subplot(2, 2, 1); zoom(1.2); title('Left lateral');
            else
                view(90, -20); subplot(2, 2, 3); zoom(1.2); title('Left medial');
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
            
            view(120,20);
            camlight('headlight', 'infinite');
            view(300,20);
            camlight('headlight', 'infinite');
            if(i == 1)
                view(100, 10); subplot(2, 2, 2); zoom(1.2); title('Right lateral');
            else
	      view(-100, -20); subplot(2, 2, 4); zoom(1.2); title('Right medial'); colorbar;
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



