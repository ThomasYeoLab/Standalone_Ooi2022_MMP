#! /bin/csh -f

# checks!
if($#argv < 2) then
    echo "usage: psf_ComputeSurfSNRSubjectList.csh SUBJECTS_DIR SUBJECT_LIST"
    echo "assumes subject has been processed by procsurffast.csh and procsurffast outputs in <SUBJECTS_DIR>/<SUBJECT>"
    exit
endif

set sdir = $1
set subjects = `cat $2`

foreach s ($subjects)
    set cmd = ($CODE_DIR/procsurffast/qc/psf_ComputeSurfSNRSingleSub.csh $s ${s}_FS $sdir);
    echo $cmd
    eval $cmd
end
