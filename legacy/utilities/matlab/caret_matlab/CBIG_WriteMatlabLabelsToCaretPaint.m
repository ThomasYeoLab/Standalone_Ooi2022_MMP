function CBIG_WriteMatlabLabelsToCaretPaint(mesh_name, input_labels_mat, left_output, right_output, paintnames_txt, exit_flag)

% CBIG_WriteMatlabLabelsToCaretPaint(mesh_name, input_labels_mat, left_output, right_output, paintnames_txt, exit_flag)
%
% Converts matlab labels (e.g. from clustering output) to caret space
%
% mesh_name = freesurfer mesh resolution: fsaverage4, fsaverage5, fsaverage6, fsaverage 
% input_labels_mat = matlab file containing lh_labels and rh_labels
% left_output = left paint filename
% right_output = right paint filename
% exit_flag = if 1, then exit matlab at the end of this function. This is useful if calling from shell or with CBIG_WriteFSLabelsInTxtFilesToCaretPaint.m
% 
% If paintnames_txt = 'NONE', then
%   vertices = 0 will be set to FS.000.label, vertices = 1 will be set to FS.001.label, etc.
% else
%   vertices = 0 will be set to first line of paintnames_txt, vertices = 1
%   will be set to second line of paintnames_txt, etc.
%
% example usage: 
%       mesh_name = 'fsaverage5';
%       input_labels_mat = fullfile(getenv('CBIG_CODE_DIR'), '/stable_projects/brain_parcellation/Yeo2011_fcMRI_clustering/1000subjects_reference/1000subjects_clusters007_ref.mat');
%       CBIG_WriteMatlabLabelsToCaretPaint(mesh_name, input_labels_mat, 'lh.output.paint', 'rh.output.paint', 'NONE', 0)
% 
%       mesh_name = 'fsaverage5';
%       input_labels_mat = fullfile(getenv('CBIG_CODE_DIR'), '/stable_projects/brain_parcellation/Yeo2011_fcMRI_clustering/1000subjects_reference/1000subjects_clusters007_ref.mat');
%       paintnames_txt = fullfile(getenv('CBIG_CODE_DIR'), '/utilities/matlab/caret_matlab/7Network_paintnames_txt');
%       CBIG_WriteMatlabLabelsToCaretPaint(mesh_name, input_labels_mat, 'lh.output.paint', 'rh.output.paint', paintnames_txt, 0)
%
%       mesh_name = 'fsaverage5';
%       input_labels_mat = fullfile(getenv('CBIG_CODE_DIR'), '/stable_projects/brain_parcellation/Yeo2011_fcMRI_clustering/1000subjects_reference/1000subjects_clusters017_ref.mat');
%       paintnames_txt = fullfile(getenv('CBIG_CODE_DIR'), '/utilities/matlab/caret_matlab/17Network_paintnames_txt');
%       CBIG_WriteMatlabLabelsToCaretPaint(mesh_name, input_labels_mat, 'lh.output.paint', 'rh.output.paint', paintnames_txt, 0)
%
% Written by CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md


if(ischar(exit_flag))
    exit_flag = str2num(exit_flag);
end

if(~strcmp(paintnames_txt, 'NONE'))
    % read paint list
    fid = fopen(paintnames_txt, 'r');
    paintnames = textscan(fid, '%s');
    paintnames = paintnames{1};
    fclose(fid);
end


parms.SUBJECTS_DIR = fullfile(getenv('FREESURFER_HOME'), 'subjects');
basedir = dirname(which('CBIG_WriteMatlabLabelsToCaretPaint'));
caret_dir = fullfile(basedir, 'fs2caret_deformations');

for hemi = {'lh' 'rh'}

    tmp_dir = fullfile(dirname(left_output), [hemi{1} 'labels' num2str(round(rand(1)*1000000))]);
    disp(['Creating dummy folder ' tmp_dir]);
    system(['mkdir -p ' tmp_dir]);

    % read data
    load(input_labels_mat);
    avg_mesh = CBIG_ReadNCAvgMesh(hemi{1}, mesh_name, 'sphere', 'cortex');

    % upsample
    disp('Sampling labels to fsaverage');
    avg_mesh7 = CBIG_ReadNCAvgMesh(hemi{1}, 'fsaverage', 'sphere', 'cortex');
    if(strcmp(hemi{1}, 'lh'))
        labels7 = MARS_NNInterpolate_kdTree(avg_mesh7.vertices, avg_mesh, lh_labels');
    else
        labels7 = MARS_NNInterpolate_kdTree(avg_mesh7.vertices, avg_mesh, rh_labels');
    end

    if(~strcmp(paintnames_txt, 'NONE'))
        if( (max(labels7)+1) > length(paintnames))
            error('There are more labels than there are paintnames');
        end
    end
    
    
    % write new label file into dummy folder
    disp('Write label into dummy folder');
    for i = 0:max(labels7)
        
        lindex = transpose(find(labels7 == i));
        if(~isempty(lindex))
            lxyz   = avg_mesh7.vertices(:, lindex)';
            lvals  = zeros(size(lindex));
            
            label_file = fullfile(tmp_dir, ['FS.' num2str(i, '%03d') '.label']);
            write_label(lindex-1, lxyz, lvals, label_file);
        end
    end
    
    % convert label file to caret format
    disp('convert label file to caret format');
    if(strcmp(hemi{1}, 'lh'))
        system(['caret_command -file-convert -fsl2c ' tmp_dir ' ' fullfile(parms.SUBJECTS_DIR, 'fsaverage', 'surf', [hemi{1} '.pial.asc']) ' ' left_output]);
    else
        system(['caret_command -file-convert -fsl2c ' tmp_dir ' ' fullfile(parms.SUBJECTS_DIR, 'fsaverage', 'surf', [hemi{1} '.pial.asc']) ' ' right_output]);
    end
        
    % deform label file to PALS
    disp('Deform label file to PALS');
    if(strcmp(hemi{1}, 'lh'))
        output = left_output;
        system(['caret_command -deformation-map-apply ' fullfile(caret_dir, ['FSaverage-to-PALS.' hemi{1} '.163842.deform_map']) ' PAINT ' left_output ' ' left_output]);
    else
        output = right_output;
        system(['caret_command -deformation-map-apply ' fullfile(caret_dir, ['FSaverage-to-PALS.' hemi{1} '.163842.deform_map']) ' PAINT ' right_output ' ' right_output]);
    end
    
    % remove dummy directory
    disp(['Remove dummy directory ' tmp_dir])
    system(['rm -r ' tmp_dir]);
    
    % Convert to binary format
    disp(['Convert paint to binary format']);
    system(['caret_command -file-convert -format-convert BINARY ' output]);
    
    % replace old paintnames with new paintnames
    if(~strcmp(paintnames_txt, 'NONE'))
        disp('Replace old paintnames with new paintnames');
        paint = caret_load(output);
        new_paintnames = paint.paintnames;
        for i = 0:max(labels7)
            for j = 1:length(paint.paintnames)
                if(strcmp(paint.paintnames{j}, ['FS.' num2str(i, '%03d') '.label']))
                    new_paintnames{j} = paintnames{i+1};
                end
            end
        end
        paint.paintnames = new_paintnames;
        caret_savepaint(output, paint)
    end
end

if(exit_flag)
  exit
end
