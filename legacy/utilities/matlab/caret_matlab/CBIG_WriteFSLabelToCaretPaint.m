function CBIG_WriteFSLabelToCaretPaint(hemi, mesh_name, input_label_files, output_caret_number_vec, output_file, exit_flag)

% CBIG_WriteFSLabelToCaretPaint(hemi, mesh_name, input_label_files, output_caret_number_vec, output_file, exit_flag)
% 
% Converts freesurfer label file from freesurfer space to caret space.
%
% hemi = 'lh' or 'rh'
% mesh_name = freesurfer mesh resolution: fsaverage4, fsaverage5, fsaverage6, fsaverage 
% input_label_files = either freesurfer label file (*.label) or if you have a whole range of label files, pass it in as a cell.
%                     You should make sure that the input label files are not overlapping.       
% output_caret_num_vec = vector of numbers telling how each input label file is mapped into caret labels FS.???.label
%                        For example, if this is [2 5], then first label file is mapped to FS.002.label. Second label file is mapped to FS.005.label
%                        Note that the numbers should also be unique.       
% output_file = caret output ; accepted format = .paint
% exit_flag = if 1, then exit matlab at the end of this function. This is useful if calling from shell or with CBIG_WriteFSLabelsInTxtFilesToCaretPaint.m
%
% example usage: 
%       CBIG_WriteFSLabelToCaretPaint('rh', 'fsaverage5', '/autofs/space/pgolland_002/users/ythomas/randy/code/FC/fssubjects/fsaverage5/label/rh.Medial_wall.label', 0, 'test/rh.test.paint', 0)
%       CBIG_WriteFSLabelToCaretPaint('lh', 'fsaverage5', '/autofs/space/pgolland_002/users/ythomas/randy/code/FC/fssubjects/fsaverage5/label/lh.Medial_wall.label', 0, 'test/lh.test.paint', 0)
% 
%       CBIG_WriteFSLabelToCaretPaint('lh', 'fsaverage5', {'lh.parcel1.label', 'lh.parcel2.label'}, [2 5], 'lh.output.paint', 0);
%
% Written by CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md


if(ischar(exit_flag))
   exit_flag = str2num(exit_flag); 
end

if(ischar(output_caret_number_vec))
   output_caret_number_vec = str2num(output_caret_number_vec); 
end

parms.SUBJECTS_DIR = fullfile(getenv('FREESURFER_HOME'), 'subjects');
basedir = dirname(which('CBIG_WriteFSLabelToCaretPaint'));
caret_dir = fullfile(basedir, 'fs2caret_deformations');


tmp_dir = fullfile(dirname(output_file), [hemi 'labels' num2str(round(rand(1)*1000000))]);
disp(['Creating dummy folder ' tmp_dir]);
system(['mkdir -p ' tmp_dir]);

if(length(unique(output_caret_number_vec)) < length(output_caret_number_vec)) 
    error('output_caret_number_vec not unique');
end

for i = 1:length(output_caret_number_vec)
    
    if(iscell(input_label_files))
        input_label_file = input_label_files{i};
    else
        input_label_file = input_label_files;
    end
    output_caret_number = output_caret_number_vec(i);
    
    % read data
    disp('reading label');
    labels = read_label([], input_label_file);
    avg_mesh = CBIG_ReadNCAvgMesh(hemi, mesh_name, 'sphere', 'cortex');
    avg_mesh.MARS_label(:) = 0;
    avg_mesh.MARS_label(labels(:, 1) + 1) = 1;

    % upsample
    disp('Sampling labels to fsaverage');
    avg_mesh7 = CBIG_ReadNCAvgMesh(hemi, 'fsaverage', 'sphere', 'cortex');
    labels7 = MARS_NNInterpolate(avg_mesh7.vertices, avg_mesh, avg_mesh.MARS_label);

    % write new label file into dummy folder
    disp('Write label into dummy folder');
    lindex = transpose(find(labels7 == 1));
    if(~isempty(lindex))
        lxyz   = avg_mesh7.vertices(:, lindex)';
        lvals  = zeros(size(lindex));

        label_file = fullfile(tmp_dir, ['FS.' num2str(output_caret_number, '%03d') '.label']);
        write_label(lindex-1, lxyz, lvals, label_file);
    else
        error('no label vertices found on fsaverage');
    end
end

% convert label file to caret format
disp('convert label file to caret format');
system(['caret_command -file-convert -fsl2c ' tmp_dir ' ' fullfile(parms.SUBJECTS_DIR, 'fsaverage', 'surf', [hemi '.pial.asc']) ' ' output_file]);

% deform label file to PALS
disp('Deform label file to PALS');
system(['caret_command -deformation-map-apply ' fullfile(caret_dir, ['FSaverage-to-PALS.' hemi '.163842.deform_map']) ' PAINT ' output_file ' ' output_file]);

% remove dummy directory
disp(['Remove dummy directory ' tmp_dir])
system(['rm -r ' tmp_dir]);

if(exit_flag)
  exit
end
