#! /bin/csh -f

# checks!
if($#argv < 8) then
    echo "usage: ClusterfcMRISurf2VolProfilesSubjectList.csh SUBJECTS_DIR SUBJECT_LIST output_prefix surf_cluster_input profile_prefix vol_mask lh_surf_profiles rh_surf_profiles"
    echo ""
    exit
endif     

set sdir = $1
set subjects = `cat $2`
set output_prefix = $3
set output_dir = `dirname $output_prefix`
mkdir -p $output_dir
set surf_cluster_input = $4
set profile_prefix = $5
set vol_mask = $6
set lh_surf_profiles = $7
set rh_surf_profiles = $8

set profile_input = ${output_prefix}_profile.txt
rm $profile_input
foreach s ($subjects)
   echo "$sdir/$s/surf2vol_profiles/lh.$s.$profile_prefix.roifsaverage3.thres0.1.surf2vol_profile.mat" >> $profile_input
end

set cmd = ($CODE_DIR/fcMRI_clustering/ClusterfcMRISurf2VolProfiles.csh $profile_input $surf_cluster_input $output_prefix $vol_mask $lh_surf_profiles $rh_surf_profiles)
echo $cmd
eval $cmd







