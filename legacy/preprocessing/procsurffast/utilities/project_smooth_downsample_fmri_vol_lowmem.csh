#! /bin/csh -f

# checks!
if($#argv < 10) then
    echo "usage: project_smooth_downsample_fmri_vol_lowmem.csh anat_base anat_s file_list reg_list fs_volsmooth fs_volsmooth_mask mni_volsmooth mni_volsmooth_mask output_dir cleanup"
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
set MATLAB=`which $_HVD_MATLAB_DIR/bin/matlab`
if($status) then
   echo "ERROR: could not find matlab"
   exit 1;
endif

set count = 1
foreach f ($input_files)
    if(! -e $f) then
        echo "ERROR: input file $f not found"
        exit 1;
    endif
    set ext = `$root_dir/grab_extension.csh $f`
    set basef = `basename $f $ext`

    set outputFS_2mm  = $output_dir/${basef}_FS1mm_FS2mm$ext
    set outputMNI_2mm = $output_dir/${basef}_FS1mm_MNI1mm_MNI2mm$ext

    if($fs_volsmooth > 0) then
	set final_FS_output = $output_dir/${basef}_FS1mm_FS2mm_sm$fs_volsmooth$ext
    else
	set final_FS_output = $outputFS_2mm
    endif

    if($mni_volsmooth > 0) then
	set final_MNI_output = $output_dir/${basef}_FS1mm_MNI1mm_MNI2mm_sm$mni_volsmooth$ext
    else
	set final_MNI_output = $outputMNI_2mm
    endif


    if((! -e $final_FS_output) || (! -e $final_MNI_output)) then 
	### --- project fMRI to freesurfer and MNI152 nonlinear volumetric space
	set reg = $reg_files[$count]
	if(! -e $reg) then
	    echo "ERROR: reg file $reg not found"
	    exit 1;
	endif    

	### --- process individual fMRI frames
	set frame_dir = $output_dir/${basef}_frames

	if(-e $frame_dir) then
	    echo "Warning: $frame_dir already exists"
	endif
	mkdir -p $frame_dir

	set output_prefix = $frame_dir/orig_frames
	set cmd = "fslsplit $f $output_prefix -t"
	echo $cmd
	eval $cmd
	echo

	set frames  = `ls $frame_dir/orig_frames*nii.gz`
	set nframes = $#frames
	if($nframes == 0) then
	    echo "Writing 4D volume $f to individual frames failed!"
	    exit 1;
	endif

	### --- project and downsample individual fMRI frames    
	set FS_dir = $frame_dir/FS_dir
	if(-e $FS_dir) then
	    echo "Warning: $FS_dir already exists"
	endif	
	mkdir -p $FS_dir

	set MNI_dir = $frame_dir/MNI_dir
	if(-e $MNI_dir) then
	    echo "Warning: $MNI_dir already exists"
	endif
	mkdir -p $MNI_dir

	set fcount = 0;
	while($fcount < $nframes)
	    
	    set fcount_str = `echo $fcount | awk '{printf ("%04d",$1)}'`

	    # deform fMRI to freesurfer nonlinear volumetric 1mm space 
	    set SUBJECTS_DIR = $anat_dir
	    setenv SUBJECTS_DIR $anat_dir
	    set input_f  = $frame_dir/orig_frames${fcount_str}.nii.gz
	    set output_f = $FS_dir/FS${fcount_str}.1mm.nii.gz

	    if(! -e $output_f) then
		set cmd = ($mri_vol2vol_used --mov $input_f --s $anat_s --targ $FREESURFER_HOME/average/mni305.cor.mgz --m3z talairach.m3z --reg $reg --o $output_f --no-save-reg --interp trilin)
		echo $cmd
		eval $cmd
	    else
		echo "projection to $output_f completed"
	    endif

	    # deform fMRI to MNI152 1mm space
	    set SUBJECTS_DIR = $root_dir
	    setenv SUBJECTS_DIR $root_dir
	    set input_f  = $FS_dir/FS${fcount_str}.1mm.nii.gz
	    set output_f = $MNI_dir/MNI${fcount_str}.1mm.nii.gz

	    if(! -e $output_f) then
		set cmd = ($mri_vol2vol_used --mov $SUBJECTS_DIR/FSL_MNI152_FS/mri/norm.mgz --s FSL_MNI152_FS --targ $input_f --m3z talairach.m3z --o $output_f --no-save-reg --inv-morph --interp trilin)
		echo $cmd
		eval $cmd        
	    else
		echo "projection to $output_f completed"
	    endif

	    # downsample fMRI in freesurfer nonlinear volumetric 1mm space to 2mm 
	    set SUBJECTS_DIR = $anat_dir
	    setenv SUBJECTS_DIR $anat_dir
	    set input_f  = $FS_dir/FS${fcount_str}.1mm.nii.gz
	    set output_f = $FS_dir/FS${fcount_str}.2mm.nii.gz 
	    
	    if(! -e $output_f) then
		set cmd = ($mri_vol2vol_used --mov $input_f --s $anat_s --targ $root_dir/gca_mean2mm.nii.gz --o $output_f --regheader --no-save-reg)
		echo $cmd
		eval $cmd
	    else
		echo "Dowsampling to $output_f completed"
	    endif

	    # downsample fMRI in MNI152 nonlinear volumetric 1mm space to 2mm
	    set SUBJECTS_DIR = $root_dir
	    setenv SUBJECTS_DIR $root_dir
	    set input_f  = $MNI_dir/MNI${fcount_str}.1mm.nii.gz
	    set output_f = $MNI_dir/MNI${fcount_str}.2mm.nii.gz 

	    if(! -e $output_f) then
		set cmd = ($mri_vol2vol_used --mov $input_f --s FSL_MNI152_FS --targ $root_dir/gca_mean2mm.nii.gz --o $output_f --regheader --no-save-reg)
		echo $cmd
		eval $cmd
	    else
		echo "Dowsampling to $output_f completed"
	    endif

	    @ fcount = $fcount + 1
	end	
	
	# --- Smooth fMRI in freesurfer nonlinear volumetric space
	set method = gaussian
	set kernel_size = 5
	set outside_smooth_type = SMOOTH
	set input_prefix = $FS_dir/FS
	set input_file_type = .2mm$ext
	set start = 0
	@ stop = $nframes - 1 

	if($fs_volsmooth > 0) then

	    set smoothed_files = `ls $FS_dir/FS.sm$fs_volsmooth.*.2mm.nii.gz`
            if($nframes == $#smoothed_files) then
                echo "FS smoothing completed!"
            else
		set output_prefix = $FS_dir/FS.sm$fs_volsmooth.
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

		Smooth3DFrames $input_prefix $start $stop $input_file_type $output_prefix $fs_volsmooth_mask $outside_smooth_type $method $kernel_size $std	

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
	    endif
	endif

	# --- Smooth fMRI in MNI nonlinear volumetric space
	set method = gaussian
	set kernel_size = 5
	set outside_smooth_type = SMOOTH
	set input_prefix = $MNI_dir/MNI
	set input_file_type = .2mm$ext
	set start = 0
	@ stop = $nframes - 1

	if($mni_volsmooth > 0) then

	    set smoothed_files = `ls $MNI_dir/MNI.sm$mni_volsmooth.*.2mm.nii.gz`	
	    if($nframes == $#smoothed_files) then
		echo "MNI smoothing completed!"
	    else
		set output_prefix = $MNI_dir/MNI.sm$mni_volsmooth.
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

		Smooth3DFrames $input_prefix $start $stop $input_file_type $output_prefix $mni_volsmooth_mask $outside_smooth_type $method $kernel_size $std

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
	    endif
	endif

	# --- Combine frames
	if($fs_volsmooth > 0) then
	    set cmd = "fslmerge -t $final_FS_output $FS_dir/FS.sm$fs_volsmooth.*.2mm.nii.gz"
            echo "fslmerge to produce final $final_FS_output from $FS_dir/FS.sm$fs_volsmooth.*.2mm.nii.gz"
	else
	    set cmd = "fslmerge -t $final_FS_output $FS_dir/FS*.2mm.nii.gz"
            echo "fslmerge to produce final $final_FS_output from $FS_dir/FS*.2mm.nii.gz"
	endif
	eval $cmd
	echo

	if($mni_volsmooth > 0) then	
	    set cmd = "fslmerge -t $final_MNI_output $MNI_dir/MNI.sm$mni_volsmooth.*.2mm.nii.gz"
	    echo "fslmerge to produce final $final_MNI_output from $MNI_dir/MNI.sm$mni_volsmooth.*.2mm.nii.gz"
	else
	    set cmd = "fslmerge -t $final_MNI_output $MNI_dir/MNI*.2mm.nii.gz"	    
	    echo "fslmerge to produce final $final_MNI_output from $MNI_dir/MNI*.2mm.nii.gz"
	endif
        eval $cmd
	echo

	if((-e $final_FS_output) && (-e $final_MNI_output)) then
	    if($cleanup) then	    
	        rm -rf $frame_dir
	    endif	
	else
	    echo "Failed to produce $final_FS_output or $final_MNI_output"
	    exit 1;	
	endif
	echo
    else
	echo "Completed: $final_FS_output"
	echo "Completed: $final_MNI_output"
    endif

    @ count = $count + 1
end
echo









