#! /bin/csh -f

## -----------
## --- checks!
## -----------
if($#argv < 8) then
    echo "usage: project_smooth_downsample_fmri.csh anat_dir anat_s input_file_list reg_list surfsmooth fsprojresolution fsresolution output_dir"
    exit
endif

set anat_dir = $1
set anat_s = $2
set input_file_list = $3
set reg_list = $4
set surfsmooth = $5
set fsprojresolution = $6
set fsresolution = $7
set output_dir = $8
set SUBJECTS_DIR = $anat_dir
setenv SUBJECTS_DIR $anat_dir

set root_dir = `dirname $0`

# check templates either symmetric or non-symmetric fsaverage
if($fsprojresolution != fsaverage & $fsprojresolution != fsaverage6 & $fsprojresolution != fsaverage5 & $fsprojresolution != fsaverage4 & \
   $fsprojresolution != lrsym_fsaverage & $fsprojresolution != lrsym_fsaverage6 & $fsprojresolution != lrsym_fsaverage5 & $fsprojresolution != lrsym_fsaverage4) then
    echo "ERROR: fsprojresolution = $fsprojresolution is not acceptable (allowable values = fsaverage, fsaverage6, fsaverage5, fsaverage4, lrsym_fsaverage, lrsym_fsaverage6, lrsym_fsaverage5, lrsym_fsaverage4)"
    exit 1;
endif

if($fsresolution != fsaverage & $fsresolution != fsaverage6 & $fsresolution != fsaverage5 & $fsresolution != fsaverage4 & \
   $fsresolution != lrsym_fsaverage & $fsresolution != lrsym_fsaverage6 & $fsresolution != lrsym_fsaverage5 & $fsresolution != lrsym_fsaverage4) then
    echo "ERROR: fsresolution = $fsresolution is not acceptable (allowable values = fsaverage, fsaverage6, fsaverage5, fsaverage4, lrsym_fsaverage, lrsym_fsaverage6, lrsym_fsaverage5, lrsym_fsaverage4)"
    exit 1;
endif

# figure out whether symmetric or not
if($fsprojresolution == fsaverage | $fsprojresolution == fsaverage6 | $fsprojresolution == fsaverage5 | $fsprojresolution == fsaverage4) then
    set symm = 0;
else if($fsresolution == lrsym_fsaverage | $fsresolution == lrsym_fsaverage6 | $fsresolution == lrsym_fsaverage5 | $fsresolution == lrsym_fsaverage4) then
    set symm = 1;
else
    echo "ERROR: $fsresolution not recognized!"
    exit 1;
endif




## ---------------------------------------
## --- grab input volumes and registration
## ---------------------------------------
set input_files = `cat $input_file_list`
set reg_files = `cat $reg_list`
if($#input_files != $#reg_files) then
    echo "ERROR: # files ($input_file_list) not equal # reg ($reg_list)"
    exit 1;
endif

## ------------------------------------------------------------------------
## --- fsaverage needs to be in the anat_dir, so temporarily creating links
## ------------------------------------------------------------------------
if(-d $FREESURFER_HOME/subjects/$fsprojresolution) then
    ln -s $FREESURFER_HOME/subjects/$fsprojresolution $anat_dir/$fsprojresolution
else
    echo "WARNING: $fsprojresolution not found in $FREESURFER_HOME/subjects/ ..."
    echo "       : USING private copy: $ROOT_DIR/code/templates/surface/$fsresolution"
    if(-d $ROOT_DIR/code/templates/surface/$fsprojresolution) then
	ln -s $ROOT_DIR/code/templates/surface/$fsprojresolution $anat_dir/$fsprojresolution
    else
	echo "ERROR: $ROOT_DIR/code/templates/surface/$fsprojresolution does not exist!"
	exit 1;
    endif
endif

if(-d $FREESURFER_HOME/subjects/$fsresolution) then
    ln -s $FREESURFER_HOME/subjects/$fsresolution $anat_dir/$fsresolution
else
    echo "WARNING: $fsresolution not found in $FREESURFER_HOME/subjects/ ..."
    echo "       : USING private copy: $ROOT_DIR/code/templates/surface/$fsresolution"
    if(-d $ROOT_DIR/code/templates/surface/$fsresolution) then
	ln -s $ROOT_DIR/code/templates/surface/$fsresolution $anat_dir/$fsresolution
    else
	echo "ERROR: $ROOT_DIR/code/templates/surface/$fsresolution does not exist!"
	exit 1;
    endif
endif


## -------------------------------------
## --- project data to $fsprojresolution
## -------------------------------------
mkdir -p $output_dir
set count = 1
foreach f ($input_files)
    
    if(! -e $f) then
	echo "ERROR: input file $f not found"
	exit 1;
    endif

    set reg = $reg_files[$count]
    if(! -e $reg) then
	echo "ERROR: reg file $reg not found"
	exit 1;
    endif


    set ext = `$root_dir/grab_extension.csh $f`
    set basef = `basename $f $ext`
    foreach hemi (lh rh)

	set output = $output_dir/$hemi.${basef}_$fsprojresolution$ext
        if(! -e $output) then
            set cmd = "mri_vol2surf --mov $f --reg $reg --hemi $hemi --projfrac 0.5 --trgsubject $fsprojresolution --o $output --reshape --interp trilinear"
            echo $cmd
            eval $cmd
        else
            echo "Projection of fMRI onto surface completed for $hemi.${basef}_$fsprojresolution$ext"
        endif

	if(! -e $output) then
	    exit 1;
	endif
    end

    @ count = $count + 1
end
echo

## -------------------------------
## --- smooth fMRI data on surface
## -------------------------------
foreach f ($input_files)

    set ext = `$root_dir/grab_extension.csh $f`
    set basef = `basename $f $ext`
    foreach hemi (lh rh)

	set input = $output_dir/$hemi.${basef}_$fsprojresolution$ext
	set output = $output_dir/$hemi.${basef}_${fsprojresolution}_sm$surfsmooth$ext
    
	if(! -e $output) then
	    if($surfsmooth > 0) then
		set cmd = "mri_surf2surf --hemi $hemi --s $fsprojresolution --sval $input --cortex --fwhm-trg $surfsmooth --tval $output --reshape"
	    else
		set cmd = "mri_surf2surf --hemi $hemi --s $fsprojresolution --sval $input --cortex --tval $output --reshape"
	    endif
	    echo $cmd
	    eval $cmd
	else
	    echo "Smoothing of fMRI on $fsprojresolution completed for $hemi.${basef}_${fsprojresolution}_sm$surfsmooth$ext"
	endif  
    
	if(! -e $output) then
	    exit 1;
	endif
    end
end
echo
 
## ------------------------------
## --- downsample fMRI on surface
## ------------------------------

set fsprojres = `echo -n $fsprojresolution | tail -c -1`
if($fsprojres == "e") then
    set fsprojres = 7;
endif

set fsres =  `echo -n $fsresolution | tail -c -1`
if($fsres == "e") then
    set fsres = 7;
endif

if($fsres > $fsprojres) then
    echo "ERROR: fsprojresolution ($fsprojresolution) < fsresolution ($fsresolution)"
    exit 1;
endif

foreach f ($input_files)
    set ext = `$root_dir/grab_extension.csh $f`
    set basef = `basename $f $ext`
    foreach hemi (lh rh)
	set input = $output_dir/$hemi.${basef}_${fsprojresolution}_sm$surfsmooth$ext

	set curr_input = $input
	set final_output = $output_dir/$hemi.${basef}_${fsprojresolution}_sm${surfsmooth}_$fsresolution$ext
	set scale = $fsprojres
	if(! -e $final_output) then
	    if($scale == $fsres) then
		set cmd = "cp $curr_input $final_output"
		echo $cmd
		eval $cmd
	    else	
	    	while($scale > $fsres)
		  @ new_scale = $scale - 1
		  if($scale == 7) then
		    if($symm) then
			set srcsubject = lrsym_fsaverage
		    else 
			set srcsubject = fsaverage
		    endif
		  else
		    if($symm) then
			set srcsubject = lrsym_fsaverage$scale
		    else 
			set srcsubject = fsaverage$scale
		    endif
		  endif

		  if($symm) then
		    set trgsubject = lrsym_fsaverage$new_scale
		  else 
		    set trgsubject = fsaverage$new_scale
		  endif

		
		  set cmd = "mri_surf2surf --hemi $hemi --srcsubject $srcsubject --sval $curr_input --cortex --nsmooth-in 1 --trgsubject $trgsubject --tval $final_output --reshape"
		  echo $cmd
		  eval $cmd	    
		
		  set curr_input = $final_output
		  @ scale = $scale - 1
	    	end	
	    endif
        else
	    echo "Downsampling to $hemi.${basef}_${fsprojresolution}_sm${surfsmooth}_$fsresolution$ext already completed"	
        endif
    end
end
echo 


