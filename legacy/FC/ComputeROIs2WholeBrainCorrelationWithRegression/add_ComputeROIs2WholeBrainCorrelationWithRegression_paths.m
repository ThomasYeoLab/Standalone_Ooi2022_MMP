
ComputeROIs2ROIs_pwd = pwd;

cd(fullfile(getenv('CODE_DIR'), 'lib', 'matlab', 'ythomas', 'FC'));
FC_add_all_paths

cd(getenv('_HVD_SD_DIR'));
add_all_paths

addpath(fullfile(getenv('FREESURFER_HOME'), 'fsfast', 'toolbox'));
addpath(fullfile(getenv('FREESURFER_HOME'), 'matlab'));

cd(ComputeROIs2ROIs_pwd);
