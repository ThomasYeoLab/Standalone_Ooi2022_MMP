#! /bin/csh -f

# checks!
if($#argv < 4) then
    echo "usage: TransformMNIReconAll1mm2FS2mm.csh input_file output_file interp_type forward"
    echo " "
    echo " forward = 1 implies transform from MNI to FS "
    echo " valid interp_type = nearest, trilin"
    exit
endif

set curr_pwd = `pwd`

set input_file = $1
set output_file = $2
set interp_type = $3
set forward = $4

if($interp_type != nearest & $interp_type != trilin) then
    echo "interp_type $interp_type not recognized"
    exit 1
endif


# convert input_file to full path
set B = `basename $input_file`
set D = `dirname $input_file`
if(! -d $D) then
    echo "directory $D does not exist!"
    exit 1
else
    cd $D
    set input_file = `pwd`/$B
    echo $input_file
    cd $curr_pwd
endif


# convert output_file to full path
set B = `basename $output_file`
set D = `dirname $output_file`
if(! -d $D) then
    echo "directory $D does not exist!"
    exit 1
else
    cd $D
    set output_file = `pwd`/$B
    echo $output_file
    cd $curr_pwd
endif

set fs_version = `cat $FREESURFER_HOME/build-stamp.txt | sed 's@.*-v@@' | sed 's@-.*@@' | head -c 1`
if($fs_version < 5) then
    echo "WARNING: FreeSurfer version < 5, using private version of mri_vol2vol"
    set mri_vol2vol_used = $CODE_DIR/procsurffast/utilities/$_HVD_PLATFORM/mri_vol2vol
else
    set mri_vol2vol_used = `which mri_vol2vol`
endif


set FS_1mm_template = $FREESURFER_HOME/average/mni305.cor.mgz
if(! -e $FS_1mm_template) then
    echo "$FS_1mm_template does not exist";
    exit 1;
endif

set FS_2mm_template = $CODE_DIR/templates/volume/FS_nonlinear_volumetric_space_4.5/gca_mean2mm.nii.gz
if(! -e $FS_2mm_template) then
    echo "$FS_2mm_template does not exist";
    exit 1;
endif

set MNI_1mm_template = $CODE_DIR/templates/volume/FSL_MNI152_FS4.5.0/mri/norm.nii.gz
if(! -e $MNI_1mm_template) then
    echo "$MNI_1mm_template does not exist";
    exit 1;
endif

#set MNI_2mm_template = /autofs/space/lyon_006/pubsw/Linux2-2.3-x86_64/packages/fsl.64bit/4.0.0/data/standard/MNI152_T1_2mm.nii.gz


# first upsample input file to 1mm x 1mm x 1mm
if($forward == 0) then
    set cmd = ($mri_vol2vol_used --mov $input_file --targ $FS_1mm_template --o $output_file --regheader --no-save-reg --interp $interp_type)
    echo $cmd
    eval $cmd
else
    cp $input_file $output_file
endif

# perform the warp
setenv SUBJECTS_DIR $CODE_DIR/templates/volume/
set anat_s = FSL_MNI152_FS4.5.0
if($forward == 1) then # transform from MNI to FS

    set cmd = "$mri_vol2vol_used --mov $output_file --s $anat_s --targ $FS_1mm_template --m3z talairach.m3z --o $output_file --no-save-reg --interp $interp_type"
    echo $cmd
    eval $cmd
else #transform from FS to MNI

    set cmd = "$mri_vol2vol_used --mov $MNI_1mm_template --s $anat_s --targ $output_file --m3z talairach.m3z --o $output_file --no-save-reg --inv-morph --interp $interp_type"
    echo $cmd
    eval $cmd
endif


# downsample back to 2mm in the case of warping to FS 2mm space
if($forward == 1) then # use FS space
    set cmd = ($mri_vol2vol_used --mov $output_file --targ $FS_2mm_template --o $output_file --regheader --no-save-reg --interp $interp_type)
    echo $cmd
    eval $cmd
endif




