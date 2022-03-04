#! /bin/csh -f

# checks!
if($#argv < 2) then
    echo "usage: ComputefcMRISurf2SurfProfilesSubjectList.csh SUBJECTS_DIR SUBJECT_LIST"
    echo "assumes subject has been processed by procsurffast.csh and procsurffast outputs in <SUBJECTS_DIR>/<SUBJECT>"
    echo "assumes correlation profile outputs in <SUBJECTS_DIR>/<SUBJECT>/surf2surf_profiles"
    exit
endif

set sdir = $1
set subjects = `cat $2`

foreach s ($subjects)
    set cmd = ($CODE_DIR/fcMRI_clustering/ComputefcMRISurf2SurfProfiles.csh $sdir $s $sdir/$s/surf2surf_profiles/);
    echo $cmd
    eval $cmd
end
