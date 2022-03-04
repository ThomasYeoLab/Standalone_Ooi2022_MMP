function CBIG_WriteFScurvToCaretSurfaceShape(hemi, input_file, mesh_name, output_file, exit_flag)

% CBIG_WriteFScurvToCaretSurfaceShape(hemi, input_file, mesh_name, output_file, exit_flag)
%
% Converts freesurfer surface data from freesurfer space to caret space
%
% hemi = 'lh' or 'rh'
% input_file = freesurfer surface data; accepted format = .nii.gz, .mgh, freesurfer curvature format, e.g., lh.curv
% mesh_name = freesurfer mesh resolution: fsaverage4, fsaverage5, fsaverage6, fsaverage 
% output_file = caret output ; accepted format = .surface_shape
% exit_flag = if 1, then exit matlab at the end of this function. This is useful if calling from shell.
%
% example usage: 
%       CBIG_WriteFScurvToCaretSurfaceShape('lh', 'test.nii.gz', 'fsaverage5', 'test.surface_shape', 0)
%
% Written by CBIG under MIT license: https://github.com/ThomasYeoLab/CBIG/blob/master/LICENSE.md


% convert output_file to full path so mri_convert won't mess up
output_base = basename(output_file);
output_dir = dirname(output_file);
curr_dir = pwd;
cd(output_dir);
output_file = fullfile(pwd, output_base);
cd(curr_dir);

if(~isempty(strfind(input_file, '.nii.gz')) || ~isempty(strfind(input_file, '.mgh')))
    x = MRIread(input_file);
    val = x.vol(:);
else
    val = read_curv(input_file); 
end
val = val';

if(ischar(exit_flag))
   exit_flag = str2num(exit_flag); 
end

parms.SUBJECTS_DIR = fullfile(getenv('FREESURFER_HOME'), 'subjects');

basedir = dirname(which('CBIG_WriteFScurvToCaretSurfaceShape'));
caret_dir = fullfile(basedir, 'fs2caret_deformations');

avg_mesh  = CBIG_ReadNCAvgMesh(hemi, mesh_name, 'sphere', 'cortex');
avg_mesh7 = CBIG_ReadNCAvgMesh(hemi, 'fsaverage', 'sphere', 'cortex');
val7 = MARS_linearInterpolate(avg_mesh7.vertices, avg_mesh, val);
val7 = -val7;

% write as freesurfer binary file
disp('write as freesurfer binary file');
write_curv(output_file, val7, size(avg_mesh7.faces, 2));

% convert to freesurfer asc file
disp('convert to freesurfer asc file');
system(['mris_convert -c ' output_file ' ' fullfile(parms.SUBJECTS_DIR, 'fsaverage', 'surf', [hemi '.pial']) ' ' output_file '.asc']);

% convert to caret file format
disp('convert to caret file format');
system(['caret_command -file-convert -fsc2c ' output_file '.asc ' fullfile(parms.SUBJECTS_DIR, 'fsaverage', 'surf', [hemi '.pial.asc']) ' ' output_file]);
delete([output_file '.asc']);

% deform to caret PALS atlas
disp('deform to caret PALS atlas');
system(['caret_command -deformation-map-apply ' fullfile(caret_dir, ['FSaverage-to-PALS.' hemi '.163842.deform_map']) ' SURFACE_SHAPE ' output_file ' ' output_file]);

if(exit_flag)
  exit
end

