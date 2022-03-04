#!/bin/csh -f
# $Author: B.T. Thomas Yeo $ $Date: 2011/03/31$
set version = '$Id: procsurffast_nii.csh, v1.0 2015/05/05 ythomas$'
# Modified from procsurffast.csh, v1.0 2011/03/31 ythomas
###################################################
# Preamble
###################################################

# Set Default Parameters
set sdir = `pwd`;
set surfsmooth = 6; #fwhm smoothing on the surface
set fsresolution = fsaverage5
set fsprojresolution = fsaverage6
set niireorient = 0;
set volproj_flag = 0;
set volproj_lowmem = 0;
set fs_volsmooth = 6;
set fs_volsmooth_mask = NONE; 
set mni_volsmooth = 6;
set mni_volsmooth_mask = NONE;
set fcfast_flag = 1;
set skipproc = 0;
set skipanat = 0;
set cleanup = 1;
set faln = 1;
set lowmem_fast = 0;
set matlab_qc_plot = 0;
set skip = 4;
set intrasub_best_reg = 0;
set extract_frames_aft_bbreg_txt = NONE
#set root_dir = `readlink -f $0`
set root_dir = `python -c "import os; print os.path.realpath('$0')"`
set root_dir = `dirname $root_dir`
# If there are no arguments or only help flag, just print useage and exit 
if($#argv == 0) goto usage_exit;

set n = `echo $argv | egrep -e --help | wc -l`
set m = `echo $argv | egrep -e -help | wc -l`
if($n != 0 | $m != 0) then
  goto help_usage;
endif

set n = `echo $argv | egrep -e -version | wc -l`
set m = `echo $argv | egrep -e --version | wc -l`
if($n != 0 | $m != 0) then
  echo "$version"
  exit 1;
endif


# capture some environment info
set month = `date +%m`
set day = `date +%d`
set year = `date +%Y`
set hour = `date +%H`
set minute = `date +%M`
set second = `date +%S`

# print input call
echo "$0 $argv"
echo " "

# parse input
goto parse_args;
parse_args_return:

# check params
goto check_params;
check_params_return:

# print parameter set
goto print_params;
print_params_return:


###################################################
# Main code
###################################################

## -----------------------
## --- run procfast_nii/fcfast_nii
## -----------------------
echo "========= ** procfast_nii/fcfast_nii ** ====================================="
if(! $skipproc) then
    if($lowmem_fast) then
	### --- run procfast_nii with lowmem option
        set cmd = (procfast_nii -sdir $sdir -id $subject -bold $bold -tr $tr -mpr $mpr -stackcheck -nocleanup -lowmem)

	if($niireorient == 1) then
	    set cmd = ($cmd -niireorient)
	endif

        if($skip == 0) then
	    set cmd = ($cmd -noskip)
        else
	    set cmd = ($cmd -skip $skip)
        endif

        if(! $fcfast_flag && $?procsmooth) then
            set cmd = ($cmd -smooth $procsmooth)
        endif

        if($?rawdir) then
            set cmd = ($cmd -rawdir $rawdir)
        endif

	if($?anat_rawdir) then
            set cmd = ($cmd -anat_rawdir $anat_rawdir)
        endif

	if($?rawnii) then
	    set cmd = ($cmd -rawnii $rawnii)
	endif

	if($?anat_rawnii) then
	    set cmd = ($cmd -anat_rawnii ${anat_rawnii})
	endif

	if($faln == 0) then
	    set cmd = ($cmd -nofaln )
	endif

	if($matlab_qc_plot) then
	    set cmd = ($cmd -matlab_qc_plot)
	endif
        
        set cmd = ($cmd '>&' $sdir/$subject/logs/procfast_lowmem.log)
        echo "Running procfast_nii with lowmem option ... Suppressing procfast_nii print out ... Check $sdir/$subject/logs/procfast_lowmem.log for procfast_nii output ..."
    else   
	if($fcfast_flag) then  
	    ### --- run fcfast_nii
	    set cmd = (fcfast_nii -sdir $sdir -id $subject -bold $bold -tr $tr -mpr $mpr -stackcheck -nocleanup)
		

	    if($niireorient == 1) then
		set cmd = ($cmd -niireorient)
		echo "Reorientation..."
	    endif

	    if($skip == 0) then
                set cmd = ($cmd -noskip)
            else
                set cmd = ($cmd -skip $skip)
            endif

	    if($?roilist) then
		set cmd = ($cmd -roilist $roilist)
	    endif

	    if($?rawdir) then
		set cmd = ($cmd -rawdir $rawdir)
	    endif

	    if($?anat_rawdir) then
            	set cmd = ($cmd -anat_rawdir $anat_rawdir)
            endif

	    if($?rawnii) then
		set cmd = ($cmd -rawnii $rawnii)
	    endif

	    if($?anat_rawnii) then
		set cmd = ($cmd -anat_rawnii ${anat_rawnii})
	    endif

	    if($faln == 0) then
		set cmd = ($cmd -nofaln )
	    endif

	    if($matlab_qc_plot) then
                set cmd = ($cmd -matlab_qc_plot)
            endif

	    set cmd = ($cmd '>&' $sdir/$subject/logs/fcfast.log)
	    echo "Running fcfast_nii ... Suppressing fcfast_nii print out ... Check $sdir/$subject/logs/fcfast.log for fcfast_nii output ..."
	else 
	    ### --- run procfast_nii
	    set cmd = (procfast_nii -sdir $sdir -id $subject -bold $bold -tr $tr -mpr $mpr -stackcheck -nocleanup)

            if($niireorient==1) then
                set cmd = ($cmd -niireorient)
            endif


	    if($skip == 0) then
		set cmd = ($cmd -noskip)
	    else
		set cmd = ($cmd -skip $skip)
	    endif

	    if($?procsmooth) then
		set cmd = ($cmd -smooth $procsmooth)
	    endif

	    if($?rawdir) then
		set cmd = ($cmd -rawdir $rawdir)
	    endif

	    if($?anat_rawdir) then
                set cmd = ($cmd -anat_rawdir $anat_rawdir)
            endif
	
            if($?rawnii) then
                set cmd = ($cmd -rawnii $rawnii)
            endif

            if($?anat_rawnii) then
                set cmd = ($cmd -anat_rawnii ${anat_rawnii})
            endif

	    if($faln == 0) then
		set cmd = ($cmd -nofaln )
	    endif

	    if($matlab_qc_plot) then
               set cmd = ($cmd -matlab_qc_plot)
            endif
	
	    set cmd = ($cmd '>&' $sdir/$subject/logs/procfast.log)
	    echo "Running procfast_nii ... Suppressing procfast_nii print out ... Check $sdir/$subject/logs/procfast.log for procfast_nii output ..."
	endif
    endif
    echo "This will take ~1 hr per run"

    echo $cmd
    mkdir -p $sdir/$subject/logs
    eval $cmd 

    if($?) then
	echo "ERROR: procfast_nii/fcfast_nii terminates with errors"
	exit 1;
    endif

    if($lowmem_fast && $fcfast_flag) then
       set cmd = (gotofcMRI.pl -id $subject -sdir $sdir/$subject/scripts)
       echo "Running gotofcMRI.pl ..."
       eval $cmd
    endif

    if($cleanup) then
	if($fcfast_flag) then
	    rm -rf $sdir/$subject/RAW
	    rm -f $sdir/$subject/bold/*/${subject}_bld*_rest_reorient.nii.gz
	    rm -f $sdir/$subject/bold/*/${subject}_bld*_rest_reorient_skip.nii.gz
	    rm -f $sdir/$subject/bold/*/${subject}_bld*_rest_reorient_skip_faln.nii.gz
	    rm -f $sdir/$subject/bold/*/${subject}_bld*_rest_reorient_skip_faln_mc_atl.nii.gz
	    rm -f $sdir/$subject/bold/*/${subject}_bld*_rest_reorient_skip_faln_mc_atl_g7.nii.gz
	    rm -f $sdir/$subject/bold/*/${subject}_bld*_rest_reorient_skip_faln_mc_atl_g7_bpss.nii.gz
	else
	    rm -rf $sdir/$subject/RAW
	    rm -f $sdir/$subject/bold/*/${subject}_bld*_rest_reorient.nii.gz
	    rm -f $sdir/$subject/bold/*/${subject}_bld*_rest_reorient_skip.nii.gz
	    rm -f $sdir/$subject/bold/*/${subject}_bld*_rest_reorient_skip_faln.nii.gz
	    if($?procsmooth) then # If there is smoothing, then delete _atl.nii.gz
		rm -f $sdir/$subject/bold/*/${subject}_bld*_rest_reorient_skip_faln_mc_atl.nii.gz	    
	    endif
	endif
    endif
else
    echo "Skipping procfast_nii/fcfast_nii ... Assume procfast_nii/fcfast_nii output at $sdir/$subject"
endif
echo 


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

### --- grab mprage series num
set mpr = `sed -n 's@set[ \t]*highres[ \t]*=[ \t]*(\([0-9]*\)).*@\1@p' "$proc_script"`
if( "$mpr" == "" ) then
    echo "ERROR: could not find highres in $proc_script"
    exit 1
endif
if( $#mpr > 1) then
    echo "ERROR: multiple mpr $mpr found"
endif
set mpr = `echo $mpr | awk '{printf ("%03d",$1)}'`

echo "bold runs = $zpdbold"
echo "T1 = $mpr"
echo


## ----------------------
## --- Perform stackcheck
## ----------------------
echo "========= ** Perform stackcheck on raw data ** ====================="
foreach bold ($zpdbold)
   set raw_data = $sdir/$subject/bold/$bold/${subject}_bld${bold}_rest.nii
   set report_base = $sdir/$subject/qc/${subject}_bld${bold}_rest
   set cmd = "stackcheck_nifti -skip $skip -report -mean -mask -stdev -snr -plot -i $raw_data -o $report_base >& $sdir/${subject}/logs/stackcheck.log"	
   echo $cmd
   eval $cmd
end
echo

## ------------------
## --- Run freesurfer
## ------------------
echo "========= ** FreeSurfer anatomical pipeline ** ====================="
if(! $?anat_dir) then

    set anat = $sdir/$subject/anat/$mpr/${subject}_mpr$mpr.nii

    ### --- check to see if T1 exists
    if(! -e $anat) then
	echo "ERROR: Expected to find T1 $anat. Not found"
	exit 1;
    endif

    ### --- check to make sure freesurfer output doesn't exist yet
    if(-d $sdir/${subject}_FS) then
	echo "$sdir/${subject}_FS already exists." 
	echo "Delete $sdir/${subject}_FS before calling procsurffash.csh."
	echo "If $sdir/${subject}_FS contains completed freesurfer output. Use -anat_dir flag"
	exit 1;
    endif

    ### --- run freesurfer
    set cmd = "recon-all -i $anat -s ${subject}_FS -all -sd $sdir >& $sdir/${subject}/logs/freesurfer.log"
    mkdir -p $sdir/${subject}/logs/
    echo "Running freesurfer ... Suppressing freesurfer print out ... Check $sdir/$subject/logs/freesurfer.log for freesurfer output ..."
    echo "This will take ~24hrs"
    echo $cmd
    eval $cmd

    if($?) then
	echo "ERROR: FreeSurfer terminates with errors"
	exit 1;
    endif

    set anat_dir = $sdir/${subject}_FS
else
    echo "Skipping FreeSurfer anatomical pipeline ... Assumes freesurfer output at $anat_dir"
endif
echo


## -----------------------------------------------------------------------
## --- Run fcMRI preprocessing if fcfast_flag is true or only registration
## -----------------------------------------------------------------------
echo "========= ** Run fcMRI preprocessing or registration only ** ========="

set anat_base = `dirname $anat_dir`
set anat_s = `basename $anat_dir`
mkdir -p $sdir/${subject}/logs/
if($fcfast_flag) then    
    set register_only = 0;    

    set cmd = "$root_dir/utilities/preprocess_fcMRI_slave.csh $sdir $subject $anat_base $anat_s $register_only $intrasub_best_reg $extract_frames_aft_bbreg_txt >& $sdir/$subject/logs/fcMRI.log"
    echo "Running fcMRI preprocessing ... Suppressing fcMRI print out ... Check $sdir/$subject/logs/fcMRI.log for fcMRI preprocessing output ..."
    echo "This will take ~0.5hrs"
    echo $cmd
    eval $cmd

    if($?) then
	echo "ERROR: $root_dir/utilities/preprocess_fcMRI_slave.csh terminates with errors"
	exit 1;
    endif

    if($cleanup) then
	rm -f $sdir/$subject/bold/*/${subject}_bld*_rest_reorient_skip_faln_mc_g1000000000.nii.gz
	rm -f $sdir/$subject/bold/*/${subject}_bld*_rest_reorient_skip_faln_mc_g1000000000_bpss.nii.gz
    endif
else
    set register_only = 1;    
    set cmd = "$root_dir/utilities/preprocess_fcMRI_slave.csh $sdir $subject $anat_base $anat_s $register_only $intrasub_best_reg $extract_frames_aft_bbreg_txt >& $sdir/$subject/logs/fcMRI_register.log"
    echo "Running intrasubject registration ... Suppressing registration print out ... Check $sdir/$subject/logs/fcMRI_register.log for registration output ..."
    echo "This will take ~0.25hrs per run"
    echo $cmd
    eval $cmd 

    if($?) then
	echo "ERROR: $root_dir/utilities/preprocess_fcMRI_slave.csh (registration only) terminates with errors"
	exit 1;
    endif
endif
echo

## -------------------------------------------------------
## --- Grab intrasubject (T2*-T1) registration cost values
## -------------------------------------------------------
echo "========= ** Grabbing intrasubject registration cost values ** ====================="
set reg_cost_file = $sdir/$subject/qc/intrasub_reg.dat
foreach f ($zpdbold)
    cat $sdir/$subject/bold/$f/${subject}_bld${f}_rest_reorient_skip_faln_mc.register.dat.mincost | awk '{print $1}' >> $reg_cost_file
end
echo


## ---------------------------
## --- Project fMRI to surface
## ---------------------------
echo "========== ** Project fMRI to surface ** ===================="
set anat_base = `dirname $anat_dir`
set anat_s = `basename $anat_dir`

### --- Create list of volume files (and corresponding registration) to be projected to the surface
mkdir -p $sdir/${subject}/logs/
set file_list = $sdir/$subject/logs/file_list.$$.txt;
set reg_list = $sdir/$subject/logs/reg_list.$$.txt;
rm $file_list
rm $reg_list
if($fcfast_flag) then
    foreach f ($zpdbold) 
	echo $sdir/$subject/bold/$f/${subject}_bld${f}_rest_reorient_skip_faln_mc_g1000000000_bpss_resid.nii.gz >> $file_list
	echo $sdir/$subject/bold/$f/${subject}_bld${f}_rest_reorient_skip_faln_mc.register.dat >> $reg_list
    end
else
    foreach f ($zpdbold) 
	echo $sdir/$subject/bold/$f/${subject}_bld${f}_rest_reorient_skip_faln_mc.nii.gz >> $file_list
	echo $sdir/$subject/bold/$f/${subject}_bld${f}_rest_reorient_skip_faln_mc.register.dat >> $reg_list
    end
endif

### --- Project, smooth and downsample fMRI
set output_dir = $sdir/$subject/surf/
set cmd = ($root_dir/utilities/project_smooth_downsample_fmri.csh $anat_base $anat_s $file_list $reg_list $surfsmooth $fsprojresolution $fsresolution $output_dir \
	   >& $sdir/$subject/logs/project_smooth_downsample.log)
mkdir -p $sdir/${subject}/logs/
echo "Project, smoothing and downsampling fMRI to surface space ... Suppressing print out ... Check $sdir/$subject/logs/project_smooth_downsample.log for processing output ..."
echo "This will take ~0.1hrs per run"
echo $cmd
eval $cmd

if($?) then
    echo "ERROR: $root_dir/utilities/project_smooth_downsample_fmri.csh terminates with errors"
    exit 1;
endif
echo


## -------------------------------------------------------------
## --- Run Surface-based Functional Connectivity on Surface ROIs 
## -------------------------------------------------------------
set script_dir = $sdir/$subject/surf_fcMRI
mkdir -p $script_dir
if($?lh_roi && $fcfast_flag) then

    echo "========== ** Computing fcMRI maps for left hemisphere seeds ** ===================="

    # create fcMRI script
    set script_name = $script_dir/lh.fcMRI.csh
    set cmd = ($root_dir/utilities/create_surf_fcMRI_script.csh lh $sdir $subject $lh_roi $script_name $surfsmooth $fsprojresolution $fsresolution \
	       >& $sdir/$subject/logs/create_surf_fcMRI_script_lh.log)
    mkdir -p $sdir/${subject}/logs/
    echo "Create surface fcMRI script for left hemisphere ... Suppressing print out ... Check $sdir/$subject/logs/create_surf_fcMRI_script_lh.log for processing output ..."
    echo "This will take 1 min"
    echo $cmd
    eval $cmd

    if($?) then
	echo "ERROR: $root_dir/utilities/create_surf_fcMRI_script.csh terminates with errors"
	exit 1;
    endif
    echo

    # run fcMRI script
    set cmd = ($script_name >& $sdir/$subject/logs/lh.fcMRI.log)
    mkdir -p $sdir/${subject}/logs/
    echo "Running fcMRI script on left hemisphere ... Suppressing print out ... Check $sdir/$subject/logs/lh.fcMRI.log for processing output ..."
    echo "This will take 1 min per ROI"
    echo $cmd
    eval $cmd

    if($?) then
	echo "ERROR: $script_name terminates with errors"
	exit 1;
    endif
    echo

endif

if($?rh_roi && $fcfast_flag) then

    echo "========== ** Computing fcMRI maps for right hemisphere seeds ** ===================="

    # create fcMRI script
    set script_name = $script_dir/rh.fcMRI.csh
    set cmd = ($root_dir/utilities/create_surf_fcMRI_script.csh rh $sdir $subject $rh_roi $script_name $surfsmooth $fsprojresolution $fsresolution\
               >& $sdir/$subject/logs/create_surf_fcMRI_script_rh.log)
    mkdir -p $sdir/${subject}/logs/
    echo "Create surface fcMRI script for right hemisphere ... Suppressing print out ... Check $sdir/$subject/logs/create_surf_fcMRI_script_rh.log for processing output ..."
    echo "This will take 1 min"
    echo $cmd
    eval $cmd

    if($?) then
	echo "ERROR: $root_dir/utilities/create_surf_fcMRI_script.csh terminates with errors"
	exit 1;
    endif
    echo
    
    # run fcMRI script
    set cmd = ($script_name >& $sdir/$subject/logs/rh.fcMRI.log)
    mkdir -p $sdir/${subject}/logs/
    echo "Running fcMRI script on right hemisphere ... Suppressing print out ... Check $sdir/$subject/logs/rh.fcMRI.log for processing output ..."
    echo "This will take 1 min per ROI"
    echo $cmd
    eval $cmd

    if($?) then
	echo "ERROR: $script_name terminates with errors"
	exit 1;
    endif
    echo
endif




## -------------------------------------------------------
## --- Project fMRI to freesurfer and MNI volumetric space
## -------------------------------------------------------
if($volproj_flag) then
    echo "=========== ** Project fMRI to FreeSurfer nonlinear volumetric Space and MNI152 space ** ============="
    set anat_base = `dirname $anat_dir`
    set anat_s = `basename $anat_dir`
    set output_dir = $sdir/$subject/vol/

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


echo "Procsurffast Completed"

exit;









################################################
# print Input and Output Parameters params;
################################################
print_params:

echo
echo "======== ** Running procsurffast_nii.csh with the following parameters ** ============="

set variable_set = (root_dir subject rawdir anat_rawdir rawnii anat_rawnii sdir tr mpr bold roilist procsmooth surfsmooth fsresolution fsprojresolution niireorient lh_roi rh_roi \
                    fcfast_flag volproj_flag volproj_lowmem fs_volsmooth fs_volsmooth_mask mni_volsmooth mni_volsmooth_mask skipproc skipanat anat_dir \
                    lowmem_fast matlab_qc_plot intrasub_best_reg skip extract_frames_aft_bbreg_txt cleanup faln)
foreach var ($variable_set)
    eval 'set isset = $?'$var
    if($isset) then  
	eval 'set setval = $'$var'';
	echo "$var = $setval";
    else
	echo "$var = NOT SET";
    endif
end
echo 

echo "========= ** Running procsurffast_nii.csh with the following software ** =============="

set variable_set = (_HVD_MATLAB_DIR FREESURFER_HOME FSFAST_HOME MNI_DIR _HVD_SPM_DIR)
foreach var ($variable_set)
    eval 'set isset = $?'$var
    if($isset) then  
	eval 'set setval = $'$var'';
	echo "$var = $setval";
    else
	echo "$var = NOT SET";
    endif
end
echo 

set function_set = (fcfast_nii procfast_nii fsl_preprocess.sh flirt fcMRI_preproc_nifti.csh ComputeROIs2ROIsCorrelationWithRegression) 
foreach func ($function_set)
    set func_path = 'which '$func
    set func_path = `eval '$func_path'`
    echo "$func USED = $func_path"
end
echo

goto print_params_return;


################################################
# parse args
################################################

parse_args:

set cmdline = ($argv);
while( $#argv != 0 )

  set flag = $argv[1]; shift;
  switch($flag)

    case "-subject":
    case "-s":
      if ( $#argv == 0) goto arg1err;
      set subject = `basename $argv[1]`; shift;
      breaksw

    case "-rawdir":
      if ( $#argv == 0) goto arg1err;
      #set rawdir = `readlink -f $argv[1]`; 
      set rawdir = `python -c "import os; print os.path.realpath('$argv[1]')"`	
      if($#rawdir == 0) then
	  echo "rawdir = $argv[1] does not exist" 
	  exit 1;
      endif
      shift;
      breaksw
  
    case "-anat_rawdir":
      if ( $#argv == 0) goto arg1err;
      set anat_rawdir = `python -c "import os; print os.path.realpath('$argv[1]')"`
      if($#anat_rawdir == 0) then
          echo "anat_rawdir = $argv[1] does not exist"
          exit 1;
      endif
      shift;
      breaksw

    case "-rawnii":
      if ( $#argv == 0) goto arg1err;
      set rawnii = `python -c "import os; print os.path.realpath('$argv[1]')"`
      if($#rawnii == 0) then
          echo "rawnii = $argv[1] does not exist"
          exit 1;
      endif
      shift;
      breaksw

    case "-anat_rawnii":
      if ( $#argv == 0) goto arg1err;
      set anat_rawnii = `python -c "import os; print os.path.realpath('$argv[1]')"`
      if($#anat_rawnii == 0) then
          echo "anat_rawnii = $argv[1] does not exist"
          exit 1; 
      endif
      shift;
      breaksw

    case "-niireorient":
      set niireorient = 1;
      breaksw


    case "-sdir": #subject directory
      if ( $#argv == 0) goto arg1err;
      #set sdir = `readlink -f $argv[1]`;
      set sdir = `python -c "import os; print os.path.realpath('$argv[1]')"` 
      if($#sdir == 0) then
	  echo "sdir = $argv[1] does not exist" 
	  exit 1;
      endif
      shift;
      breaksw

    case "-tr":
      if ( $#argv == 0) goto arg1err;
      set tr = `basename $argv[1]`; shift;
      breaksw

    case "-mpr":
      if ( $#argv == 0) goto arg1err;
      set mpr = `basename $argv[1]`; shift;
      breaksw

    case "-bold":
      if ( $#argv == 0) goto arg1err;
      set bold = `basename $argv[1]`; shift;
      breaksw

    case "-roilist":
      if ( $#argv == 0) goto arg1err;
      #set roilist = `readlink -f $argv[1]`; 
      set roilist = `python -c "import os; print os.path.realpath('$argv[1]')"`
      if($#roilist == 0) then
	  echo "roilist = $argv[1] does not exist" 
	  exit 1;
      endif
      shift;
      breaksw  

    case "-procsmooth":
      if ( $#argv == 0) goto arg1err;
      set procsmooth = `basename $argv[1]`; shift;
      breaksw  

    case "-surfsmooth":
      if ( $#argv == 0) goto arg1err;
      set surfsmooth = `basename $argv[1]`; shift;
      breaksw 

    case "-fsresolution":
      if ( $#argv == 0) goto arg1err;
      set fsresolution = `basename $argv[1]`; shift;
      breaksw 

    case "-fsprojresolution":
      if ( $#argv == 0) goto arg1err;
      set fsprojresolution = `basename $argv[1]`; shift;
      breaksw 

    case "-procfast":
      set fcfast_flag = 0; # run procfast_nii instead
      breaksw;

    case "-intrasub_best_reg":
      set intrasub_best_reg = 1; # use best registration
      breaksw;

    case "-lh_roi":
      if ( $#argv == 0) goto arg1err;
      #set lh_roi = `readlink -f $argv[1]`; 
      set lh_roi = `python -c "import os; print os.path.realpath('$argv[1]')"`	
      if($#lh_roi == 0) then
	  echo "lh_roi = $argv[1] does not exist" 
	  exit 1;
      endif
      shift;
      breaksw   

    case "-rh_roi":
      if ( $#argv == 0) goto arg1err;
      set rh_roi = `python -c "import os; print os.path.realpath('$argv[1]')"`      
      #set rh_roi = `readlink -f $argv[1]`; 
      if($#rh_roi == 0) then
	  echo "rh_roi = $argv[1] does not exist" 
	  exit 1;
      endif
      shift;
      breaksw 

    case "-skipproc":
      set skipproc = 1; # fcfast_nii/procfast_nii has already been run
      breaksw;  

    case "-anat_dir":
      set skipanat = 1; 
      if ( $#argv == 0) goto arg1err;
      #set anat_dir = `readlink -f $argv[1]`; 
      set anat_dir = `python -c "import os; print os.path.realpath('$argv[1]')"`
      if($#anat_dir == 0) then
	  echo "anat_dir = $argv[1] does not exist" 
	  exit 1;
      endif
      shift;
      breaksw;     

    case "-volproj":
      set volproj_flag = 1; 
      breaksw;

    case "-volproj_lowmem":
      set volproj_flag = 1; 
      set volproj_lowmem = 1;
      breaksw;

    case "-lowmem_fast":
      set lowmem_fast = 1; # low memory option is evoked.
      breaksw;

    case "-matlab_qc_plot":
      set matlab_qc_plot = 1; # use matlab instead of gnuplot for qc plots
      breaksw;

    case "-skip":
      if ( $#argv == 0) goto arg1err;
      set skip = `basename $argv[1]`; shift;
      breaksw

    case "-fs_volsmooth":
      if ( $#argv == 0) goto arg1err;
      set fs_volsmooth = `basename $argv[1]`; shift;
      breaksw 

    case "-fs_volsmooth_mask"
      if ( $#argv == 0) goto arg1err;
      #set fs_volsmooth_mask = `readlink -f $argv[1]`;
      set fs_volsmooth_mask = `python -c "import os; print os.path.realpath('$argv[1]')"`
      if($#fs_volsmooth_mask == 0) then
	  echo "fs_volsmooth_mask = $argv[1] does not exist"
	  exit 1;  
      endif
      shift;
      breaksw 

    case "-mni_volsmooth":
      if ( $#argv == 0) goto arg1err;
      set mni_volsmooth = `basename $argv[1]`; shift;
      breaksw 

    case "-mni_volsmooth_mask"
      if ( $#argv == 0) goto arg1err;
      #set mni_volsmooth_mask = `readlink -f $argv[1]`;
      set mni_volsmooth_mask = `python -c "import os; print os.path.realpath('$argv[1]')"`
      if($#mni_volsmooth_mask == 0) then
	  echo "mni_volsmooth_mask = $argv[1] does not exist"
	  exit 1;  
      endif
      shift;
      breaksw 

    case "-extract_frames_aft_bbreg":
      if ( $#argv == 0) goto arg1err;
      set extract_frames_aft_bbreg_txt = `python -c "import os; print os.path.realpath('$argv[1]')"`
      if($#extract_frames_aft_bbreg_txt == 0) then
          echo "extract_frames_aft_bbreg = $argv[1] does not exist"
          exit 1;
      endif
      shift;
      breaksw

    case "-nocleanup":
      set cleanup = 0;
      breaksw;  

    case "-nofaln":
      set faln = 0;
      breaksw;

    default:
      echo ERROR: Flag $flag unrecognized.
      echo $cmdline
      exit 1
      breaksw
  endsw

end

goto parse_args_return;


arg1err:
  echo "ERROR: flag $flag requires one argument"
  exit 1

################################################
# check_params
################################################

check_params:

# For procfast_nii/fcfast_nii to occur, need to specify either subject or rawdir
if($skipproc == 0 & (! $?subject) &  (! $?rawdir) & (! $?rawnii) ) then
    echo "ERROR: For procfast_nii/fcfast_nii to occur, need to specify either subject or rawdir or raw NIfTI files!"
    exit 1;
endif

# For procfast_nii/fcfast_nii to occur, need to specify tr, mpr, bold
if($skipproc == 0) then
    set variable_set = (tr mpr bold)
    foreach var ($variable_set)
	eval 'set isset = $?'$var
	if(! $isset) then  
	    echo "ERROR: For procfast_nii/fcfast_nii to occur, need to specify $var"
	    exit 1;
	endif
    end 
endif

# To skip freesurfer pipeline, need to specify anat_dir
if($skipanat == 1 & (! $?anat_dir)) then
    echo "ERROR: To skip freesurfer pipeline, need to specify anat_dir"
    exit 1
endif

# Check that anat_rawdir, rawdir, sdir, anat_dir exists
set directory_set = (rawdir anat_rawdir sdir anat_dir)
foreach direc ($directory_set)
    eval 'set isset = $?'$direc
    if($isset) then
	set actual_dir = '$'$direc
 	eval 'set actual_dir = '$actual_dir
	if(! -d $actual_dir) then
	    echo "ERROR: $direc is set to $actual_dir but does not exist"
	    exit 1;
	endif
    endif
end

# check that roilist exists
set file_set = (roilist lh_roi rh_roi)
foreach file ($file_set)
    eval 'set isset = $?'$file
    if($isset) then
	set actual_file = '$'$file
 	eval 'set actual_file = '$actual_file
	if(! -e $actual_file) then
	    echo "ERROR: $file is set to $actual_file but does not exist"
	    exit 1;
	endif
    endif
end

# check that extract_frames_aft_bbreg_txt exists
if($extract_frames_aft_bbreg_txt == "NONE") then

else
    if(! -e $extract_frames_aft_bbreg_txt) then
        echo "ERROR: extract_frames_aft_bbreg_txt is set to $extract_frames_aft_bbreg_txt but does not exist"
        exit 1;
    endif
endif

# check that subject is set
if(! $?subject) then
    echo "ERROR: subject variable not set";
    exit 1;
endif

# check if smoothing is set for procfast_nii
if($skipproc == 0 & $fcfast_flag == 0 & (! $?proc_smooth)) then
    echo "WARNING: proc_smooth not set for procfast_nii. So no smoothing is going to take place"
endif

#if($fsprojresolution != fsaverage & $fsprojresolution != fsaverage6 & $fsprojresolution != fsaverage5 & $fsprojresolution != fsaverage4 & \
#   $fsprojresolution != lrsym_fsaverage & $fsprojresolution != lrsym_fsaverage6 & $fsprojresolution != lrsym_fsaverage5 & $fsprojresolution != lrsym_fsaverage4) then
#    echo "ERROR: fsprojresolution = $fsprojresolution is not acceptable (allowable values = fsaverage, fsaverage6, fsaverage5, fsaverage4, lrsym_fsaverage, lrsym_fsaverage6, lrsym_fsaverage5, lrsym_fsaverage4)"
#    exit 1;
#endif

#if($fsresolution != fsaverage & $fsresolution != fsaverage6 & $fsresolution != fsaverage5 & $fsresolution != fsaverage4 & \
#   $fsresolution != lrsym_fsaverage & $fsresolution != lrsym_fsaverage6 & $fsresolution != lrsym_fsaverage5 & $fsresolution != lrsym_fsaverage4) then
#    echo "ERROR: fsresolution = $fsresolution is not acceptable (allowable values = fsaverage, fsaverage6, fsaverage5, fsaverage4, lrsym_fsaverage, lrsym_fsaverage6, lrsym_fsaverage5, lrsym_fsaverage4)"
#    exit 1;
#endif


if($fsprojresolution != fsaverage & $fsprojresolution != fsaverage6 & $fsprojresolution != fsaverage5 & $fsprojresolution != fsaverage4) then
    echo "ERROR: fsprojresolution = $fsprojresolution is not acceptable (allowable values = fsaverage, fsaverage6, fsaverage5, fsaverage4)"
    exit 1;
endif

if($fsresolution != fsaverage & $fsresolution != fsaverage6 & $fsresolution != fsaverage5 & $fsresolution != fsaverage4) then
    echo "ERROR: fsresolution = $fsresolution is not acceptable (allowable values = fsaverage, fsaverage6, fsaverage5, fsaverage4)"
    exit 1;
endif

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

goto check_params_return;




################################################
# help
################################################
usage_exit:
  echo ""
  echo "USAGE: procsurffast_nii.csh"
  echo ""
  echo "Inputs"
  echo "  -s, -subject <subject>            : subject's ID"
  echo "  -rawdir <rawdir>                  : specify path to raw data directory if data is not located in archive [optional]"
  echo "  -anat_rawdir <anat_rawdir>        : specify path to anat raw data directory if anat data is not located in archive or rawdir [optional]"
  echo "  -rawnii <rawnii>		    : specify path to a text file that lists (full) paths to raw functional NIfTI files. This option cannot be used with -rawdir"
  echo "				      Each line corresponds to 1 functional NIfTI file. The corresponding run numbers are specified in -bold (in sequence)"
  echo "				      Example of <rawnii> content:"
  echo "					/Data/RAWNII/070519_4TT00247_run1.nii.gz"
  echo "                                        /Data/RAWNII/070519_4TT00247_run2.nii.gz"
  echo "  -anat_rawnii <anat_rawnii>	    : specify path to a text file that lists (full) path to the raw anatomical NIfTI file (only 1 file can be specified). Run number is specified by -mpr."
  echo "				      This option cannot be used with -anat_rawdir. Example of <anat_rawnii> content:"
  echo "                                        /Data/ANATRAWNII/070519_4TT00247_anat.nii.gz"
  echo "  -niireorient			    : specify whether reorientation of raw NIfTI files need to be performed (both anat and func). Default is NO reorientation"
  echo "				      To decide whether reorientation is required, load volumes on freeview. If the following statements are true, you do not need to reorient your data:"
  echo "					- Scroll down coronal, 2nd voxel coordinate decreases"
  echo "					- Scroll down sagittal, 1st voxel coordinate increases"
  echo "					- Scroll down axial, 3rd voxel coordinate decreases"
  echo "					  Note that the niireorient flag is only active if nifty is passed in. The flag is ignored even if the flag is set"
  echo "  -sdir <sdir>                      : specify location to save processed results or the directory where subject data" 
  echo "                                      can be found if procfast_nii/fcfast_nii has already been run. In particular,"
  echo "                                      processed data is assumed to be at or saved at <sdir>/<subject>."
  echo "                                      [optional; defaults to current directory]"
  echo "                                      IMPORTANT: Note that if <rawdir> = <sdir>/<subject>/RAW, then procfast_nii/fcfast_nii will delete your RAW data!"
  echo "                                      IMPORTANT: Note that if <anat_rawdir> = <sdir>/<subject>/RAW_ANAT, then procfast_nii/fcfast_nii will delete your RAW ANAT data!"
  echo "  -tr <tr>                          : specify sampling rate in sec [optional if skipping procfast_nii/fcfast_nii]"
  echo "  -mpr <mpr>                        : specify t1 weighted mprage number [optional if skipping procfast_nii/fcfast_nii]"
  echo "  -bold <bold_runs>                 : specify bold run numbers followed by a comma (e.g. -bold 5,6,13) [optional if skipping procfast_nii/fcfast_nii]"
  echo "  -roilist <roi_list>               : specify seed regions in a text list [optional if using fcfast_nii; not needed otherwise]"i
  echo "  -skip <skip>                      : specify number of initial fMRI frames to remove [optional; default: $skip]"
  echo "  -nofaln			    : do not perform slice time correction (default is performed)"
  echo " "
  echo " "
  echo "  -procsmooth <kernel>              : specify in mm the FWHM of a gaussian kernel to smooth preprocessed data in atlas" 
  echo "                                      space for procfast_nii. Not used by fcfast_nii. fcfast_nii smoothing is fixed to 6mm"
  echo "                                      [optional for procfast_nii; not needed otherwise]"
  echo "  -surfsmooth <kernel>              : specify in mm the FWHM of smoothing surface data in fsaverage space [optional; default: $surfsmooth]"
  echo "  -fsresolution <avg_surf>          : specify final freesurfer surface [optional; default: $fsresolution]"
  echo "  -fsprojresolution <avg_surf>      : specify freesurfer surface for initial projection [optional; default:  $fsprojresolution]"
  echo "                                      Allowable choices: fsaverage, fsaverage6, fsaverage5, fsaverage4"
  echo "  -lh_roi <lh_roi.txt>              : specify left hemisphere seed regions in a text list. Seed regions are assumed to be binary mask in the form of nii.gz, mgh, mgz or label. "
  echo "                                      Surface-based fcMRI is then computed for each seed to both left and right hemisphere"
  echo "                                      [optional; possible roi list = $_HVD_CODE_DIR/ComputeROIs2ROIsCorrelationWithRegression/Yeo2011_surface_seeds/lh.surface_seeds.txt]"
  echo "  -rh_roi <rh_roi.txt>              : specify right hemisphere seed regions in a text list. Seed regions are assumed to be binary mask in the form of nii.gz, mgh, mgz or label."
  echo "                                      Surface-based fcMRI is then computed for each seed to both left and right hemisphere"
  echo "                                      [optional; possible roi list = $_HVD_CODE_DIR/ComputeROIs2ROIsCorrelationWithRegression/Yeo2011_surface_seeds/rh.surface_seeds.txt]"
  echo " "
  echo "  -volproj                          : Also project fMRI data to freesurfer and MNI volumetric space. Note that a bug in mri_vol2vol "
  echo "                                      means that a large amount of RAM (25GB) is needed [optional; default = $volproj_flag]"
  echo "  -volproj_lowmem		    : Also project fMRI data to freesurfer and MNI volumetric space. But uses minimal RAM compared with volproj option."
  echo "				      This operation works by operating on individual frames, but results in large number of input/output to disk."
  echo "  -fs_volsmooth <kernel>            : specify in mm the FWHM of smoothing volumetric data in freesurfer nonlinear volumetric" 
  echo "                                      space [optional; default: $fs_volsmooth]"
  echo "                                      "
  echo "  -fs_volsmooth_mask <mask>         : mask for smoothing in freesurfer nonlinear volumetric space. "
  echo "                                      Smoothing is performed separately within and outside the mask [optional; default: $fs_volsmooth_mask]"
  echo "                                      For example, you can use the mask here: $_HVD_CODE_DIR/templates/volume/FS_nonlinear_volumetric_space_4.5/SubcortCerebellumWhiteMask.GCA.t0.5.nii.gz"
  echo "                                      which was created with the following freesurfer command:  mri_binarize --i $_HVD_CODE_DIR/templates/volume/FS_nonlinear_volumetric_space_4.5/gca_labels2mm.nii.gz"
  echo "                                      --match 7 --match 8 --match 9 --match 10 --match 11 --match 12 --match 13 --match 17 --match 18 --match 26 --match 27 --match 28 --match 46 --match 47 "
  echo "                                      --match 48 --match 49 --match 50 --match 51 --match 52 --match 53 --match 54 --match 58 --match 59 --match 60 --o SubcortCerebellumWhiteMask.GCA.t0.5.nii.gz"
  echo "                                      The structures corresponding to the numbers follow that of the FreeSurfer colortable ($FREESURFER_HOME/FreeSurferColorLUT.txt)"
  echo " "
  echo "  -mni_volsmooth <kernel>           : specify in mm the FWHM of smoothing volumetric data in MNI152 space"
  echo "                                      space [optional; default: $mni_volsmooth]"
  echo "  -mni_volsmooth_mask <mask>        : mask for smoothing in MNI152 space. "
  echo "                                      Smoothing is performed separately within and outside the mask [optional; default: $mni_volsmooth_mask]"
  echo " "
  echo " "
  echo "  -procfast                         : run procfast_nii instead of fcfast_nii [optional; default runs fcfast_nii]"  
  echo "  -skipproc                         : skip both fcfast_nii and procfast_nii. Processed data is assumed to be in <sdir>/<subject>"
  echo "                                      Assume procfast_nii/fcfast_nii has been run with nocleanup option"
  echo "                                      If -procfast is not specified, then assume preprocessed data is fcMRI data"
  echo "                                      else assumed to be normal fMRI data [optional; default skipproc = 0]"
  echo "  -anat_dir <anat_dir>              : By specifying anat directory, get to skip the freesurfer pipeline. If this is not"
  echo "                                      specified, procsurffast_nii will run freesurfer on the data, and outputs to <sdir>/<subject>_FS/"
  echo "                                      Therefore anat_dir should point to the equivalent of <sdir>/<s>_FS [optional]" 
  echo "  -lowmem_fast                      : This disables fcMRI preprocessing in the MNI152 space as defined by fcfast_nii; instead run procfast_nii with lowmem option"
  echo "                                      Useful when dealing with data with larger number of time points on machines with lower RAM"
  echo "  -matlab_qc_plot                   : This uses matlab to perform the qc plot in fsl_preprocess.sh instead of gnuplot. Useful for MacOSX. "                       
  echo "  -intrasub_best_reg                : If this option is used, bbregister (intrasubject bold to T1 registration) is run with both spm and fsl initialization"
  echo "                                      Across both types of initializations and all the runs, the registration with the best cost function value is used"
  echo "                                      This of course assumes motion correction is done very well"
  echo "                                      IMPT NOTE: If this option is used, it is necessary that spm is in your matlab paths. For example, this can be achieved"
  echo "                                      by adding this line: addpath(getenv('_HVD_SPM_DIR')); in your startup.m file"
  echo "                                      In practice, motion correction tends to be more robust that bold-T1 registration, so this option is recommended"
  echo "  -extract_frames_aft_bbreg <file>  : If this option is used, <file> is a text file where each line specifies frames to be kept for each corresponding bold run"
  echo "                                      after intrasubject registration. The format of each line follows that of a string passed to str2num in matlab. Index starts from 1, NOT 0"
  echo "                                      For example, if the second line in <file> is 23:25 80, then frames 23,24,25 and 80 will be kept for the second bold run"
  echo "  -nocleanup                        : do not remove intermediate files"
  echo " "
  echo " "
  echo "  --version, -version"
  echo "  --help, -help                     : comprehensive explanation about the pipeline and usage"
  echo "  "
  echo "$version"

  exit 1;

#################################################
#
#################################################
help_usage:
  echo "OVERVIEW:"
  echo " "
  echo "  The pipeline processes fMRI data and projects the data to "
  echo "      (1) MNI152 space as defined by fcfast_nii/procfast_nii"
  echo "      (2) FreeSurfer fsaverage space" 
  echo "      (3) FreeSurfer nonlinear volumetric space"
  echo "      (4) FSL MNI52 space. "
  echo " "
  echo "  The pipeline proceeds sequentially as follows:"
  echo "      (1) Runs fcfast_nii on resting data. "
  echo "                user can also request procfast_nii instead if processing task-based fMRI (using -procfast flag)."
  echo "                can also skip this step if user already processed data (using -skipproc flag)"
  echo "      (2) Runs freesurfer pipeline on T1. "
  echo "                user can skip this step if user already processed anatomical data (using -anat_dir <path to freesurfer processed data> "
  echo "      (3) Compute registration of motion corrected fMRI with freesurfer processed T1"
  echo "      (4) Perform fcMRI preprocessing on motion corrected fMRI data (under fcfast_nii mode)"
  echo "      (5) Project fcMRI preprocessed data (or motion corrected fMRI data under procfast mode) to surface, smooth and downsample to desired resolution. "
  echo "                output can be found in the directory <sdir>/<subject>/surf/ "
  echo "      (6) If -lh_roi or -rh_roi are used, run seed-based fcMRI on left and right hemispheres"
  echo "      (7) If -volproj or volproj_lowmem flag is selected, then project fcMRI preprocessed data (or motion corrected fMRI data under procfast mode) to "
  echo "          FreeSurfer nonlinear volumetric space and FSL MNI152 space, downsampled to 2mm and smoothed. "
  echo "                Volume projection is not the default because current version of mri_vol2vol has a bug, causing it to use up 25GB of RAM "
  echo "                when performing the projection, so currently this step is only feasible on launchpad. "
  echo "                Volume projection lowmem uses much less RAM by operating on individual frames, but inflicts large input/output read/write to disk"
  echo "                output can be found in the directory <sdir>/<subject>/vol/ "
  echo " "
  echo " "
  echo "EXAMPLE USAGE:"
  echo " "
  echo "  procsurffast_nii.csh -s 100401_HW84YH -tr 3 -mpr 5 -bold 14,15"
  echo "  procsurffast_nii.csh -s 100401_HW84YH -tr 3 -mpr 5 -bold 14,15 -roilist <roi_list>"
  echo "       -- provides fcfast_nii with roi_list for functional connectivity (see fcfast_nii for usage of this option)." 
  echo "  procsurffast_nii.csh -s 100401_HW84YH -tr 3 -mpr 5 -bold 14,15 -lh_roi $_HVD_CODE_DIR/ComputeROIs2ROIsCorrelationWithRegression/Yeo2011_surface_seeds/lh.surface_seeds.txt"
  echo "       -- performs whole cortex (left and right hemi) fcMRI using left hemisphere seed regions as specified in text files" 
  echo "  procsurffast_nii.csh -s 100401_HW84YH -tr 3 -mpr 5 -bold 14,15 -procfast"
  echo "       -- run procfast_nii instead of fcfast_nii"
  echo "       -- motion-corrected fMRI projected instead of fcMRI processed fMRI"
  echo "  procsurffast_nii.csh -s 100401_HW84YH -tr 3 -mpr 5 -bold 14,15 -sdir yada/yada -skipproc"
  echo "       -- assumes fcfast_nii has been already been run with nocleanup option"
  echo "       -- assumes fcfast_nii output is in yada/yada/100401_HW84YH"
  echo "  procsurffast_nii.csh -s 100401_HW84YH -tr 3 -mpr 5 -bold 14,15 -anat_dir foo/bar"
  echo "       -- assumes freesurfer pipeline has already been run"
  echo "       -- assumes freesurfer output is in foo/bar, i.e., foo/bar contains freesurfer directories mri, surf, etc, ..."
  echo "  procsurffast_nii.csh -s 100401_HW84YH -tr 3 -mpr 5 -bold 14,15 -volproj"
  echo "       -- also projects data to freesurfer nonlinear volumetric space and FSL MNI152 space via FreeSurfer nonlinear volumetric space"
  echo "  procsurffast_nii.csh -s 100401_HW84YH -tr 3 -mpr 5 -bold 14,15 -volproj_lowmem"
  echo "       -- also projects data to freesurfer nonlinear volumetric space and FSL MNI152 space via FreeSurfer nonlinear volumetric space"
  echo "  procsurffast_nii.csh -s 100401_HW84YH -rawdir /Data/RAW/100401_HW84YH -tr 5.0 -mpr 3 -bold 5,6 -sdir /Data/Processed/100401_HW84YH"
  echo "       -- run procsurffast_nii with DICOM input"
  echo "  procsurffast_nii.csh -s 100401_HW84YH -rawnii /Data/RAWNII/100401_HW84YH_funclist.txt -anat_rawnii /Data/RAWANATNII/100401_HW84YH_anatlist.txt -tr 5.0 -mpr 3 -bold 5,6 -sdir /Data/Processed/100401_HW84YH"
  echo "       -- run procsurffast_nii with NIfTI input (no reorientation of NIfTI input files will be performed)"
  echo "  procsurffast_nii.csh -s 100401_HW84YH -rawnii /Data/RAWNII/100401_HW84YH_funclist.txt -anat_rawnii /Data/RAWANATNII/100401_HW84YH_anatlist.txt -tr 5.0 -mpr 3 -bold 5,6 -sdir /Data/Processed/100401_HW84YH -niireorient"
  echo "       -- run procsurffast_nii with NIfTI input (with reorientation of NIfTI input files)"
  echo " "
  echo " "
  echo "OUTPUTS: Procsurffast will create the directory <sdir>/<subject> as specified in the options. Within the <sdir>/<subject> folder,"
  echo "         there are multiple folders:"
  echo ""
  echo "  1. surf folder contains the intermediate and final preprocessed fMRI data on the surface. "
  echo "     For example, surf/lh.090425_QF86JB_bld014_rest_reorient_skip_faln_mc_g1000000000_bpss_resid_fsaverage6_sm6_fsaverage5.nii.gz is "
  echo '     bold data from run 14 ("bld014") subject "090425_QF86JB" that has been projected to the left hemisphere ("lh"). '
  echo '     The remaining descriptors in the filename describes the ordering of the processing that has occurred. In particular,'
  echo '          "reorient" = dimensions of bold volume has been reordered, but the header has been modified so that the volume stays in the same space.'
  echo '          "skip" = first four frames have been removed for T1 equilibrium'
  echo '          "faln" = slice time correction'
  echo '          "mc" = motion correction'
  echo '          "g1000000000" = essentially 0 smoothing'
  echo '          "bpss" = bandpass filtering'
  echo '          "resid" = regression of whole brain, ventricular, white matter, etc signal (standard fcMRI preprocessing)'
  echo '          "fsaverage6" = data projected to fsaverage6 surface'
  echo '          "sm6" = data smoothed with a 6mm kernel on the surface'
  echo '          "fsaverage5" = data downsampled to fsaverage5 surface'
  echo "  2. vol folder contains the intermediate and final preprocessed fMRI data in the MNI152 and freesurfer nonlinear volumetric space."
  echo '     For example, vol/090425_QF86JB_bld014_rest_reorient_skip_faln_mc_g1000000000_bpss_resid_FS1mm_MNI1mm_MNI2mm_sm6.nii.gz is '
  echo '     bold data from run 14 ("bld014") subject "090425_QF86JB". The remaining descriptors in the filename describes the ordering '
  echo '     of the processing that has occurred. In particular,'
  echo '          "reorient" = dimensions of bold volume has been reordered, but the header has been modified so that the volume stays in the same space.'
  echo '          "skip" = first four frames have been removed for T1 equilibrium'
  echo '          "faln" = slice time correction'
  echo '          "mc" = motion correction'
  echo '          "g1000000000" = essentially 0 smoothing'
  echo '          "bpss" = bandpass filtering'
  echo '          "resid" = regression of whole brain, ventricular, white matter, etc signal (standard fcMRI preprocessing)'
  echo '          "FS1mm" = projection of data to freesurfer nonlinear 1mm volumetric space'
  echo '          "MNI1mm" = projection of data to MNI152 nonlinear 1mm volumetric space'
  echo '          "MNI2mm" = downsampling of data to MNI152 nonlinear 2mm volumetric space'
  echo '          "sm6" = data smoothed with a 6mm kernel'
  echo '  3. surf_fcMRI folder contains the surface-based fcMRI maps computed using the left and right hemisphere seed lists and the scripts used'
  echo '     for the computation. For example,'
  echo '          "surf_fcMRI/lh.fcMRI.csh is the script used to compute the fcMRI maps of the left hemisphere"'
  echo '          "surf_fcMRI/rh.lh.MT+.mgh.fcMRI.nii.gz" is the fcMRI of left hemisphere MT+ seed region with right hemisphere'
  goto usage_exit
