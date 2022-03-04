#! /bin/csh -f

# checks!
if($#argv < 4) then
    echo "usage: ComputefcMRISurf2VolProfilesSubjectList.csh SUBJECTS_DIR SUBJECT_LIST VOL_MASK OUTPUT_PREFIX INPUT_POSTFIX"
    echo "assumes subject has been processed by procsurffast.csh and procsurffast outputs in <SUBJECTS_DIR>/<SUBJECT>"
    echo "assumes correlation profile outputs in <SUBJECTS_DIR>/<SUBJECT>/surf2vol_profiles"
    exit
endif

set sdir = $1
set subjects = `cat $2`
set vol_mask = $3
set prefix = $4

if($#argv < 5) then
    set input_postfix = FS1mm_MNI1mm_MNI2mm_sm6.nii.gz
else
    set input_postfix = $5
endif


foreach s ($subjects)
    set cmd = ($CODE_DIR/fcMRI_clustering/ComputefcMRISurf2VolProfiles_noregress.csh $sdir $s $sdir/$s/surf2vol_profiles/ $vol_mask $prefix $input_postfix);
    echo $cmd
    eval $cmd
end
