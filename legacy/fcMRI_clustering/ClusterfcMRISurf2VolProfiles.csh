#! /bin/csh -f

# checks!
if($#argv < 6) then
    echo "usage: ClusterfcMRISurf2VolProfiles_noregress.csh profile_input surf_cluster_input output_prefix vol_mask lh_surf_profiles rh_surf_profiles"
    echo ""
    exit
endif     

set profile_input = $1
set surf_cluster_input = $2
set output_prefix = $3
set output_dir = `dirname $output_prefix`
set vol_mask = $4
set lh_surf_profiles = $5
set rh_surf_profiles = $6

# average profiles
set output_base    = `basename $output_prefix`
set avg_profile = $output_dir/$output_base.avg_profile.mat

set MATLAB=`which $_HVD_MATLAB_DIR/bin/matlab`
if($status) then
    echo "ERROR: could not find matlab"
    exit 1;
endif

set input_var_name = surf2vol_correlation_profile
set output_var_name = $input_var_name
set dimcount = 2
$MATLAB -nojvm -nodesktop -nosplash -r "bty_pwd = pwd; CODE_DIR = getenv('_HVD_CODE_DIR'); cd(fullfile(CODE_DIR, 'bin')); ythomas_generic_startup; cd(bty_pwd); AvgMatlabMatrices('${profile_input}', '${input_var_name}', '${avg_profile}', '${output_var_name}', '${dimcount}'); exit;"

if(! -e $avg_profile) then
   echo "ERROR: $avg_profile not produced"
   exit 
endif

# cluster
$MATLAB -nojvm -nodesktop -nosplash -r "bty_pwd = pwd; CODE_DIR = getenv('_HVD_CODE_DIR'); cd(fullfile(CODE_DIR, 'bin')); ythomas_generic_startup; cd(bty_pwd); ClassifyBrainVolumeBasedOnSurf2VolProfile('${avg_profile}', '${vol_mask}', '${surf_cluster_input}', '${output_prefix}', '${lh_surf_profiles}', '${rh_surf_profiles}'); exit;"

if(! -e ${output_prefix}.nii.gz) then
   echo "ERROR: clustering unsuccesful. ${output_prefix}.nii.gz not produced"
   exit
endif





