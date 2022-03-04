#! /bin/csh -f
# This script will re-run the standard preprocessing pipeline from fcMRI preprocessing (i.e. spatial blurring -> bandpass filtering -> regression of movement, white matter, ventricle (+derivatives)) and then volume projection
# written by Jesisca Tandi and Thomas Yeo

# Parameters
set cleanup = 1
set mni_volsmooth_mask = NONE
set mni_volsmooth = 6
set fs_volsmooth = 6
set fs_volsmooth_mask = NONE
set volproj_lowmem = 1
set volproj_flag = 1


set subject = $1
set sdir = $2

set root_dir = $CODE_DIR/procsurffast/

## ---------------------------
## --- fcMRI preprocessing
## ---------------------------
cd $sdir
set cmd = "${root_dir}/NoGlobalRegVolume/fcMRI_preproc_nifti_NoGlobalRegress.csh $subject >& $sdir/$subject/logs/fcMRI_preprocess.log"
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
echo $fcbold
set zpdbold = ""
@ k = 1
while ($k <= ${#fcbold})
   set zpdbold = ($zpdbold `echo $fcbold[$k] | awk '{printf ("%03d",$1)}'`)
   @ k++
end

set anat_dir = $sdir/${subject}_FS

### --- Create list of volume files (and corresponding registration) to be projected to the MNI space
mkdir -p $sdir/${subject}/logs/
set file_list = $sdir/$subject/logs/file_list.$$.txt;
set reg_list = $sdir/$subject/logs/reg_list.$$.txt;
rm $file_list
rm $reg_list

foreach f ($zpdbold) 
    echo $sdir/$subject/bold/$f/${subject}_bld${f}_rest_reorient_skip_faln_mc_g1000000000_bpss_resid.nii.gz >> $file_list
    echo $sdir/$subject/bold/$f/${subject}_bld${f}_rest_reorient_skip_faln_mc.register.dat >> $reg_list
end



## -------------------------------------------------------
## --- Project fMRI to freesurfer and MNI volumetric space
## -------------------------------------------------------
if($volproj_flag) then
    echo "=========== ** Project fMRI to FreeSurfer nonlinear volumetric Space and MNI152 space ** ============="
    set anat_base = `dirname $anat_dir`
    set anat_s = `basename $anat_dir`
    set output_dir = $sdir/$subject/vol/

    mkdir -p ${output_dir}
    if($volproj_lowmem) then
        set cmd = ($root_dir/utilities/project_smooth_downsample_fmri_vol_lowmem.csh $anat_base $anat_s $file_list $reg_list $fs_volsmooth $fs_volsmooth_mask $mni_volsmooth $mni_volsmooth_mask $output_dir $cleanup \
               >& $sdir/$subject/logs/project_smooth_downsample_vol_lowmem.log)
        echo "Project, smoothing and downsampling fMRI to vol space ... Suppressing print out ... Check $sdir/$subject/logs/project_smooth_downsample_vol_lowmem.log for processing output ..."
    else
        set cmd = ($root_dir/utilities/project_smooth_downsample_fmri_vol.csh $anat_base $anat_s $file_list $reg_list $fs_volsmooth $fs_volsmooth_mask $mni_volsmooth $mni_volsmooth_mask $output_dir $cleanup \
               >& $sdir/$subject/logs/project_smooth_downsample_vol.log)
        echo "Project, smoothing and downsampling fMRI to vol space ... Suppressing print out ... Check $sdir/$subject/logs/project_smooth_downsample_vol.log for processing output ..."
    endif
    mkdir -p $sdir/${subject}/logs/
    echo "This will take ~5hrs per bold run of 300 time points"
    echo $cmd
    eval $cmd

    if($?) then
        if($volproj_lowmem) then
            echo "ERROR: $root_dir/utilities/project_smooth_downsample_fmri_vol_lowmem.csh terminates with errors"
        else
            echo "ERROR: $root_dir/utilities/project_smooth_downsample_fmri_vol.csh terminates with errors"
        endif
        exit 1;
    endif
    echo
endif

