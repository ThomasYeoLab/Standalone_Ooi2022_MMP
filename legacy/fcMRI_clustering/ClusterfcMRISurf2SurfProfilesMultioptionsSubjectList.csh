#! /bin/csh -f

# checks!
if($#argv < 4) then
    echo "usage: ClusterfcMRISurf2SurfProfilesSubjectList.csh SUBJECTS_DIR SUBJECT_LIST num_clusters output_file"
    echo ""
    exit
endif     

set sdir = $1
set subjects = `cat $2`
set num_clusters = $3
set output_file = $4
set output_dir = `dirname $output_file`
mkdir -p $output_dir

set formated_cluster = `echo $num_clusters | awk '{printf ("%03d", $1)}'`

set lh_profile_input = ${output_file}_lh_profile.txt
rm $lh_profile_input

set rh_profile_input = ${output_file}_rh_profile.txt
rm $rh_profile_input

foreach s ($subjects)
   echo "$sdir/$s/surf2surf_profiles/lh.$s.roifsaverage3.thres0.1.surf2surf_profile.nii.gz" >> $lh_profile_input
   echo "$sdir/$s/surf2surf_profiles/rh.$s.roifsaverage3.thres0.1.surf2surf_profile.nii.gz" >> $rh_profile_input
end

set cmd = ($CODE_DIR/fcMRI_clustering/ClusterfcMRISurf2SurfProfilesMultioptions.csh $lh_profile_input $rh_profile_input $num_clusters $output_file)
echo $cmd
eval $cmd







