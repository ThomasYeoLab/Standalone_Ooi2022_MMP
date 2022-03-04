#! /bin/csh -f
# This script will re-run the standard preprocessing pipeline from fcMRI preprocessing (i.e. spatial blurring -> bandpass filtering -> regression of movement regressors (+derivatives) and 5 CompCor components), and then surface projection
# written by Jesisca Tandi and Thomas Yeo
set subject = $1
set sdir = $2

set root_dir = $CODE_DIR/procsurffast/

## ---------------------------
## --- fcMRI preprocessing
## ---------------------------
cd $sdir
set cmd = "${root_dir}/NoGlobalRegSurface/fcMRI_preproc_nifti_NoGlobalRegress.csh $subject >& $sdir/$subject/logs/fcMRI_preprocess.log"
mkdir -p $sdir/$subject/logs/
echo $cmd
eval $cmd

## ---------------------------------------------------------------
## --- Grab parameters from $sdir/$subject/scripts/$subject.params
## ---------------------------------------------------------------
echo "Grabbing parameters from $sdir/$subject/scripts/$subject.params ..."

### --- grab bold run
set proc_script = $sdir/$subject/scripts/$subject.params
if(! -e $proc_script) then
    echo "ERROR: cannot find fmri script ($proc_script)"
    exit 1;
endif
eval "`grep "fcbold" $proc_script`"

set zpdbold = ""
@ k = 1
while ($k <= ${#fcbold})
   set zpdbold = ($zpdbold `echo $fcbold[$k] | awk '{printf ("%03d",$1)}'`)
   @ k++
end

## ---------------------------
## --- Project fMRI to surface
## ---------------------------
set anat_dir = $sdir/${subject}_FS
echo "========== ** Project fMRI to surface ** ===================="
set anat_base = `dirname $anat_dir`
set anat_s = `basename $anat_dir`
set surfsmooth = 6
set fsprojresolution = fsaverage6
set fsresolution = fsaverage5

### --- Create list of volume files (and corresponding registration) to be projected to the surface
mkdir -p $sdir/${subject}/logs/
set file_list = $sdir/$subject/logs/file_list.$$.txt;
set reg_list = $sdir/$subject/logs/reg_list.$$.txt;
rm $file_list
rm $reg_list

foreach f ($zpdbold) 
    echo $sdir/$subject/bold/$f/${subject}_bld${f}_rest_reorient_skip_faln_mc_g1000000000_bpss_resid.nii.gz >> $file_list
    echo $sdir/$subject/bold/$f/${subject}_bld${f}_rest_reorient_skip_faln_mc.register.dat >> $reg_list
end

### --- Project, smooth and downsample fMRI
set output_dir = $sdir/$subject/surf/
set cmd = ($root_dir/utilities/project_smooth_downsample_fmri.csh $anat_base $anat_s $file_list $reg_list $surfsmooth $fsprojresolution $fsresolution $output_dir \
           >& $sdir/$subject/logs/project_smooth_downsample.log)
mkdir -p $sdir/${subject}/logs/
echo "Project, smoothing and downsampling fMRI to surface space ... Suppressing print out ... Check $sdir/$subject/logs/project_smooth_downsample.log for processing output ..."
echo "This will take ~0.1hrs per run"
echo $cmd
eval $cmd


