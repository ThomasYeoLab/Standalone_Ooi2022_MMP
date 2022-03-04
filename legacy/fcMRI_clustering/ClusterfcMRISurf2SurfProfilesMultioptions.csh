#! /bin/csh -f

# checks!
if($#argv < 4) then
    echo "usage: ClusterfcMRISurf2SurfProfilesMultioptions.csh lh_profile_txt rh_profile_txt num_clusters output_file"
    echo ""
    exit
endif     

set lh_profile_txt = $1
set rh_profile_txt = $2
set num_clusters = $3
set output_file = $4
set output_dir = `dirname $output_file`

set formated_cluster = `echo $num_clusters | awk '{printf ("%03d", $1)}'`

# average profiles
set output_base    = `basename $output_file`
set lh_avg_profile = $output_dir/lh.$output_base.avg_profile$formated_cluster.nii.gz
set rh_avg_profile = $output_dir/rh.$output_base.avg_profile$formated_cluster.nii.gz

set MATLAB=`which $_HVD_MATLAB_DIR/bin/matlab`
if($status) then
    echo "ERROR: could not find matlab"
    exit 1;
endif

$MATLAB -nojvm -nodesktop -nosplash -r "bty_pwd = pwd; CODE_DIR = getenv('_HVD_CODE_DIR'); cd(fullfile(CODE_DIR, 'bin')); ythomas_generic_startup; cd(bty_pwd); AvgFreeSurferVolumes('${lh_profile_txt}', '${lh_avg_profile}'); AvgFreeSurferVolumes('${rh_profile_txt}', '${rh_avg_profile}'); exit;"

if(! -e $lh_avg_profile) then
   echo "ERROR: $lh_avg_profile not produced"
   exit 
endif

if(! -e $rh_avg_profile) then
   echo "ERROR: $rh_avg_profile not produced"
   exit
endif

# cluster
set mesh = fsaverage5
set mask = cortex
set smooth = 0;
set num_tries = 1000;
set znorm = 0;

$MATLAB -nojvm -nodesktop -nosplash -r "bty_pwd = pwd; CODE_DIR = getenv('_HVD_CODE_DIR'); cd(fullfile(CODE_DIR, 'bin')); ythomas_generic_startup; cd(bty_pwd); VonmisesSeriesClusteringMultioptions('$mesh', '$mask', '$num_clusters', '$output_file', '${lh_avg_profile}', '${rh_avg_profile}', '${smooth}', '${num_tries}', '${znorm}'); exit;"

if(! -e $output_file) then
   echo "ERROR: clustering unsuccesful. $output_file not produced"
   exit
endif






