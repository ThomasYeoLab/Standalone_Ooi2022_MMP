#! /bin/csh -f

# checks!
if($#argv < 10) then
    echo "usage: project_smooth_downsample_fmri_vol.csh anat_base anat_s file_list reg_list fs_volsmooth fs_volsmooth_mask mni_volsmooth mni_volsmooth_mask output_dir cleanup"
    exit
endif

set anat_dir = $1
set anat_s = $2
set input_file_list = $3
set reg_list = $4
set fs_volsmooth = $5
set fs_volsmooth_mask = $6
set mni_volsmooth = $5
set mni_volsmooth_mask = $6
set output_dir = $9
set cleanup = $10
set root_dir = `dirname $0`

## ---------------------------------------
## --- grab input volumes and registration
## ---------------------------------------
set input_files = `cat $input_file_list`
set reg_files = `cat $reg_list`
if($#input_files != $#reg_files) then
    echo "ERROR: # files ($input_file_list) not equal # reg ($reg_list)"
    exit 1;
endif

set fs_version = `cat $FREESURFER_HOME/build-stamp.txt | sed 's@.*-v@@' | sed 's@-.*@@' | head -c 1`
if($fs_version < 5) then
    echo "WARNING: FreeSurfer version < 5, using private version of mri_vol2vol"
    set _HVD_PLATFORM = `uname`_`uname -p`
    set _HVD_PLATFORM  = `echo $_HVD_PLATFORM | tr '[:upper:]' '[:lower:]'`
    set mri_vol2vol_used = $root_dir/$_HVD_PLATFORM/mri_vol2vol
else
    set mri_vol2vol_used = `which mri_vol2vol`
endif

### --- project T1 to freesurfer nonlinear volumetric space for checking purpose
set SUBJECTS_DIR = $anat_dir
setenv SUBJECTS_DIR $anat_dir
mkdir -p $output_dir
set input  = $SUBJECTS_DIR/$anat_s/mri/norm.mgz
set output = $output_dir/norm_fsaverage_space1mm.nii.gz
if(! -e $output) then
    set cmd = ($mri_vol2vol_used --mov $input --s $anat_s --targ $FREESURFER_HOME/average/mni305.cor.mgz --m3z talairach.m3z --o $output --no-save-reg --interp trilin)
    echo $cmd
    eval $cmd
else
    echo "Projection of T1 into freesurfer nonlinear volumetric 1mm space completed"
endif

set input = $output_dir/norm_fsaverage_space1mm.nii.gz
set output = $output_dir/norm_fsaverage_space2mm.nii.gz
if(! -e $output) then
    #set cmd = ($mri_vol2vol_used --mov $input --s $anat_s --targ $root_dir/gca_mean2mm.nii.gz --o $output --reg $root_dir/id_register2mm.dat --no-save-reg)
    set cmd = ($mri_vol2vol_used --mov $input --s $anat_s --targ $root_dir/gca_mean2mm.nii.gz --o $output --regheader --no-save-reg)
    echo $cmd
    eval $cmd
else
    echo "Dowsampling of norm_fsaverage_space1mm.nii.gz to norm_fsaverage_space2mm.nii.gz completed"
endif
echo

### --- project T1 to MNI152 space for checking purpose
set SUBJECTS_DIR = $root_dir
setenv SUBJECTS_DIR $root_dir

set input  = $output_dir/norm_fsaverage_space1mm.nii.gz
set output = $output_dir/norm_MNI152_1mm.nii.gz
if(! -e $output) then
    set cmd = ($mri_vol2vol_used --mov $SUBJECTS_DIR/FSL_MNI152_FS/mri/norm.mgz --s FSL_MNI152_FS --targ $input --m3z talairach.m3z --o $output --no-save-reg --inv-morph --interp trilin)
    echo $cmd
    eval $cmd
else
    echo "Projection of T1 into FSL MNI152 1mm space completed"
endif
echo  


## -----------------------------------------------------------------
## --- project fmri to freesurfer and MNI nonlinear volumetric space
## -----------------------------------------------------------------
set count = 1
foreach f ($input_files)
    if(! -e $f) then
        echo "ERROR: input file $f not found"
        exit 1;
    endif
    set ext = `$root_dir/grab_extension.csh $f`
    set basef = `basename $f $ext`

    ### --- project fMRI to freesurfer and MNI152 nonlinear volumetric space
    set reg = $reg_files[$count]
    if(! -e $reg) then
        echo "ERROR: reg file $reg not found"
        exit 1;
    endif    

    # deform fMRI to freesurfer nonlinear volumetric 1mm space 
    set SUBJECTS_DIR = $anat_dir
    setenv SUBJECTS_DIR $anat_dir
    set output = $output_dir/${basef}_FS1mm$ext
    if(! -e $output) then
	set cmd = ($mri_vol2vol_used --mov $f --s $anat_s --targ $FREESURFER_HOME/average/mni305.cor.mgz --m3z talairach.m3z --reg $reg --o $output --no-save-reg --interp trilin)
	echo $cmd
	eval $cmd
    else
	echo "Projection of fMRI into freesurfer nonlinear volumetric 1mm space completed for ${basef}_FS1mm$ext"
    endif
    echo
    if(! -e $output) then
	exit 1;
    endif

    # deform fMRI to MNI152 1mm space
    set SUBJECTS_DIR = $root_dir
    setenv SUBJECTS_DIR $root_dir
    set input = $output_dir/${basef}_FS1mm$ext
    set output = $output_dir/${basef}_FS1mm_MNI1mm$ext
    if(! -e $output) then
	set cmd = ($mri_vol2vol_used --mov $SUBJECTS_DIR/FSL_MNI152_FS/mri/norm.mgz --s FSL_MNI152_FS --targ $input --m3z talairach.m3z --o $output --no-save-reg --inv-morph --interp trilin)
	echo $cmd
	eval $cmd
    else
	echo "Projection of fMRI into MNI152 1mm space completed for ${basef}_FS1mm_MNI1mm$ext"
    endif
    echo
    if(! -e $output) then
	exit 1;
    endif

    # downsample fMRI in freesurfer nonlinear volumetric 1mm space to 2mm 
    set SUBJECTS_DIR = $anat_dir
    setenv SUBJECTS_DIR $anat_dir
    set input = $output_dir/${basef}_FS1mm$ext
    set output = $output_dir/${basef}_FS1mm_FS2mm$ext
    if(! -e $output) then
	#set cmd = ($mri_vol2vol_used --mov $input --s $anat_s --targ $root_dir/gca_mean2mm.nii.gz --o $output --reg $root_dir/id_register2mm.dat --no-save-reg)
        set cmd = ($mri_vol2vol_used --mov $input --s $anat_s --targ $root_dir/gca_mean2mm.nii.gz --o $output --regheader --no-save-reg)
	echo $cmd
	eval $cmd
    else
	echo "Downsampling of ${basef}_FS1mm$ext to ${basef}_FS1mm_FS2mm$ext completed"
    endif
    echo
    if(! -e $output) then
	exit 1;
    else
	if($cleanup) then
	    rm -f $input
	endif
    endif


    # downsample fMRI in MNI152 nonlinear volumetric 1mm space to 2mm
    set SUBJECTS_DIR = $root_dir
    setenv SUBJECTS_DIR $root_dir
    set input = $output_dir/${basef}_FS1mm_MNI1mm$ext
    set output = $output_dir/${basef}_FS1mm_MNI1mm_MNI2mm$ext 
    if(! -e $output) then
	set cmd = ($mri_vol2vol_used --mov $input --s FSL_MNI152_FS --targ $root_dir/gca_mean2mm.nii.gz --o $output --regheader --no-save-reg)
	echo $cmd
	eval $cmd
    else
	echo "Downsampling of ${basef}_FS1mm_MNI1mm$ext to ${basef}_FS1mm_MNI1mm_MNI2mm$ext completed"
    endif
    echo
    if(! -e $output) then
	exit 1;
    else
	if($cleanup) then
	    rm -f $input
	endif
    endif

    ### --- smoothing fMRI in freesurfer nonlinear volumetric 2mm space
    set method = gaussian
    set kernel_size = 5
    set outside_smooth_type = SMOOTH

    if($fs_volsmooth > 0) then
	set input = $output_dir/${basef}_FS1mm_FS2mm$ext
	set output = $output_dir/${basef}_FS1mm_FS2mm_sm$fs_volsmooth$ext
	if(! -e $output) then
	    set std = `echo "$fs_volsmooth/2/2.35482" | bc -l` #Note that fwhm = 2.35482 * std, the second division by 2 is because each voxel is 2mm.

	    set MATLAB=`which $_HVD_MATLAB_DIR/bin/matlab`
	    if($status) then
		echo "ERROR: could not find matlab"
		exit 1;
	    endif

	    set touch_file = \'$anat_dir/$anat_s/matlab_done.touch\'

	    ################## Start Matlab 
	    $MATLAB -nojvm -display iconic -nosplash << EOF

	    addpath(fullfile(getenv('FREESURFER_HOME'), 'matlab'));
	    addpath(fullfile(getenv('FREESURFER_HOME'), 'fsfast', 'toolbox'));
	    addpath(fullfile(getenv('_HVD_CODE_DIR'), 'lib', 'matlab', 'ythomas', 'FC', 'utilities'));
	    addpath(fullfile(getenv('_HVD_CODE_DIR'), 'lib', 'matlab', 'ythomas', 'FC', 'surf'));

	    Smooth4DVolume $input $output $fs_volsmooth_mask $outside_smooth_type $method $kernel_size $std

	    if exist($touch_file,'file')
		!rm $touch_file
	    end
	    !touch $touch_file
EOF

	    ################## End Matlab (NOTE THAT EOF needs to be left aligned for some reason)

	    set touch_file = $anat_dir/$anat_s/matlab_done.touch
	    if(! -e $touch_file) then
		echo "ERROR: Matlab failed to smooth fMRI in freesurfer nonlinear volumetric space"
		exit -1;
	    else
		rm $touch_file
	    endif
	else
	    echo "Smoothing of ${basef}_FS1mm_FS2mm$ext completed"
	endif
	if(! -e $output) then
	    exit 1;
	else
	    if($cleanup) then
		rm -f $input
	    endif
	endif
    endif
    echo

    ### --- smoothing fMRI in MNI152 nonlinear volumetric 2mm space
    if($mni_volsmooth > 0) then
	set input = $output_dir/${basef}_FS1mm_MNI1mm_MNI2mm$ext
	set output = $output_dir/${basef}_FS1mm_MNI1mm_MNI2mm_sm$mni_volsmooth$ext
	if(! -e $output) then
	    set std = `echo "$mni_volsmooth/2/2.35482" | bc -l` #Note that fwhm = 2.35482 * std, the second division by 2 is because each voxel is 2mm.
	    
	    set MATLAB=`which $_HVD_MATLAB_DIR/bin/matlab`
	    if($status) then
		echo "ERROR: could not find matlab"
		exit 1;
	    endif

	    set touch_file = \'$anat_dir/$anat_s/matlab_done.touch\'
	    ################## Start Matlab 
	    $MATLAB -nojvm -display iconic -nosplash << EOF

	    addpath(fullfile(getenv('FREESURFER_HOME'), 'matlab'));
	    addpath(fullfile(getenv('FREESURFER_HOME'), 'fsfast', 'toolbox'));
	    addpath(fullfile(getenv('_HVD_CODE_DIR'), 'lib', 'matlab', 'ythomas', 'FC', 'utilities'));
	    addpath(fullfile(getenv('_HVD_CODE_DIR'), 'lib', 'matlab', 'ythomas', 'FC', 'surf'));

	    Smooth4DVolume $input $output $mni_volsmooth_mask $outside_smooth_type $method $kernel_size $std

	    if exist($touch_file,'file')
                !rm $touch_file
            end
            !touch $touch_file
EOF

            ################## End Matlab (NOTE THAT EOF needs to be left aligned for some reason)

            set touch_file = $anat_dir/$anat_s/matlab_done.touch
	    if(! -e $touch_file) then
		echo "ERROR: Matlab failed to smooth fMRI in freesurfer nonlinear volumetric space"
		exit -1;
	    else
		rm $touch_file
	    endif
	else
	    echo "Smoothing of ${basef}_FS1mm_FS2mm$ext completed"
	endif
	if(! -e $output) then
	    exit 1;
	else
	    if($cleanup) then
		rm -f $input
	    endif
	endif
    endif
    echo

    @ count = $count + 1
end
echo









