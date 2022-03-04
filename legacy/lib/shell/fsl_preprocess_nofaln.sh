#!/bin/tcsh -f
# $Date: 2015/05/07 15:00 $ 
# Modified from: $Author: ythomas $ $Date: 2011/03/28 11:33:00 $

#if (! $?FSL_DIR) setenv FSL_DIR /usr/pubsw/packages/fsl/4.0.0
#if (! $?FREESURFER_HOME) source /usr/local/freesurfer/nmr-std-env
#if (! $?FREESURFER_HOME) source /ncf/apps/freesurfer-4.0.0/SetUpFreeSurfer.sh

if (! -e $0) then
 set FSL_PREPROCESS = `which $0` #/ncf/tools/mtt24/nexus-tools/bin/fsl_preprocess.sh
else
 set FSL_PREPROCESS = $0
endif

set VERSION = '$Id: fsl_preprocess.sh,v 1.43 2011/09/26 11:33:00 ythomas Exp $'
set PREVIOUS_STABLE_VERSION = '$Id: fsl_preprocess.sh,v 1.42 2011/03/28 11:33:00 ythomas Exp $'
#set PREVIOUS_STABLE_VERSION = 'Id: fsl_preprocess.sh,v 1.41 2008/09/28 00:48:49 kahn Exp'
set printhelp = 0;
set normalize = 1; # by default, perform normalization to target atlas
set epi_normalize = 0; # if normalize is set to 0 but epi_normalize (is set to 1)
set faln = 1;      # by default, perform frame align (slice timing) correction
set fieldmap_correction = 0;
set slab = 0; # Slab epi -> whole Brain epi is not used by default
set spm_normalize = 1; # by default, use spm to normalize to target atlas
set bet_extract = 0; # by default, perform brain extraction
set cleanup = 1;
set verbose_flag = ""
set matlab_qc_plot = 0
set mc_flags = ""
set epidewarp_flags = ""
set bet_flags = ""
set spm_matlab_params = ""
set afterFirstStep = 0
set sliceTimingDim = 3
set fsl_preprocess_dir = `python -c "import os; print os.path.realpath('$0')"`
set fsl_preprocess_dir = `dirname $fsl_preprocess_dir`

#set subject = "";
set root = `pwd`;
set suffixBOLD = '';

## If there are no arguments, just print useage and exit ##
if($#argv == 0) goto usage_exit;
set n = `echo $argv | egrep -e --help | wc -l`
#set n = `echo $argv | egrep -e -h | wc -l`
if($n != 0) then
  set printhelp = 1;
  goto usage_exit;
endif

set n = `echo $argv | egrep -e --version | wc -l`
if($n != 0) then
  echo $VERSION
  exit 0;
endif

goto parse_args;
parse_args_return:

goto check_params;
check_params_return:

echo VERSION = $VERSION |& tee -a $LF
echo FSL_DIR = $FSL_DIR |& tee -a $LF
echo FREESURFER_HOME = $FREESURFER_HOME |& tee -a $LF

cd $root/$subject

#### Anatomy scans defnitions

if ($normalize) then
  echo "[DEBUG]: do normalization"
  pushd $anat
  if (! $?mprs) then
     set mprs = `ls -d */*mpr*reorient.nii.gz | awk -F "/" '{print $1}'`
     echo "[DEBUG]: mprs = $mprs"
  endif
  set zpdmprs = ""
  @ k = 1
  while ($k <= ${#mprs})
     set zpdmprs = ($zpdmprs `echo $mprs[$k] | awk '{printf ("%03d",$1)}'`)
     @ k++
  end
  echo "[DEBUG]: zpdmprs = $zpdmprs"

  echo "[DEBUG]: pwd = `pwd`"

  if (! $?highres) then
     set highres = $zpdmprs[1]/"$subject"_mpr"$zpdmprs[1]"_reorient.nii.gz
     echo "[DEBUG]: highres = $highres [1]"
     echo "[DEBUG]: subject = $subject, zpdmprs[1] = $zpdmprs[1]"
     if (! -e $highres) then
         echo "Cannot set highres target. See params file. Aborting."
         exit -1
     endif
  else
     set highres = `echo $highres | awk '{printf ("%03d",$1)}'`
     set highres = $highres/"$subject"_*_reorient.nii.gz
     echo "[DEBUG]: highres = $highres [2]"
     echo "[DEBUG]: subject = $subject"
  endif

  if (! $spm_normalize) then
    if (! $?initial_highres) then
      set initial_highres = `ls -d */"$subject"_*t1epi*_reorient.nii.gz`
      echo "[DEBUG]: initial_highres = $initial_highres"
      if (! -e $initial_highres) then
        echo "Cannot set initial_highres target. See params file. Aborting."
        exit -1
      endif
    else
      if (! -e $initial_highres) then
        set initial_highres = `echo $initial_highres | awk '{printf ("%03d",$1)}'`
        set initial_highres = `ls -d $initial_highres/"$subject"_*_reorient.nii.gz`
    	echo "[DEBUG]: initial_highres = $initial_highres"
      endif
    endif
  endif

  if ($slab) then
    echo "[DEBUG]: slab registration"
    if ($spm_normalize) then
     echo "Cannot use SPM normalization (spm_normalize = 1) with slab registration. Aborting."
     exit -1;
    endif
    if (! -e $slab_initial_highres) then
     set slab_initial_highres = `echo $slab_initial_highres | awk '{printf ("%03d",$1)}'`
     set slab_initial_highres = `ls -d $slab_initial_highres/*_reorient.nii.gz`
     echo "[DEBUG]: slab_initial_highres = $slab_initial_highres"
    endif
  endif
  popd
endif

#### Fieldmap definitions
if ($fieldmap_correction) then
  pushd $fieldmap
    set fieldmap_folders = `ls -d 0*`
    set B0_mag = $fieldmap_folders[1]/*_reorient.nii.gz
    set B0_phasediff = $fieldmap_folders[2]/*_reorient.nii.gz
    set tediff = 2.46 # Take that parameter from alTE[0] and alTE[1] in fieldmap infodump.dat (6680 - 4220 ms)
    set esp = .83 # ge_epi protocol Echo Spacing parameter
    set sigmamm = 2 # 2D spatial gaussing smoothing stddev (default 2mm)
  popd
endif


#### BOLD definitions
if(! $?skip) then
    @ skip = 4
endif
if(! $?TR_vol) then
    echo "Variable TR_vol is undefined. Aborting."
    exit -1
endif

echo "[DEBUG]: skip = $skip"
echo "[DEBUG]: TR_vol = $TR_vol"

if(! $?BOLDbasename) then
    set BOLDbasename = $subject"_bld*_*_reorient.nii.gz"
    echo "[DEBUG]: BOLDbasename = $BOLDbasename"
endif

if(! $?bold) then
    pushd $boldfolder
    set bold = `ls -d */$BOLDbasename | awk -F "/" '{print $1}'`
    echo "[DEBUG]: bold = $bold"
    popd
endif

set zpdbold = ""
@ k = 1
while ($k <= ${#bold})
   set zpdbold = ($zpdbold `echo $bold[$k] | awk '{printf ("%03d",$1)}'`)
   echo "[DEBUG]: zpdbold = $zpdbold"
   @ k++
end

#### Start processing
echo "[DEBUG]: Start processing"
pushd $boldfolder;
 set base_bold = $boldfolder/$zpdbold[1]
 echo "[DEBUG]: base_bold = $base_bold"
 if ($skip >= 0) then
    foreach curr_folder ($zpdbold)
         pushd $curr_folder
          set BOLD = `basename $BOLDbasename .nii.gz`
          @ numof_tps = `fslnvols $BOLD` - $skip
	  echo "[DEBUG]: Deleting first $skip frames (fslroi) from $BOLD$suffixBOLD"
          echo Deleting first $skip frames from $curr_folder/$BOLD$suffixBOLD '('output "$BOLD$suffixBOLD"_skip' with' $numof_tps 'frames)' |& tee -a $LF
          fslroi $BOLD$suffixBOLD ${BOLD}${suffixBOLD}_skip  $skip $numof_tps |& tee -a $LF
          #fslroi $BOLD$suffixBOLD $BOLD"$suffixBOLD"_skip  $skip $numof_tps |& tee -a $LF
          if ($cleanup && $afterFirstStep) then
            echo "[DEBUG]: removing ${BOLD}${suffixBOLD}.nii.gz (hard-coded extension)"
            rm -f ${BOLD}${suffixBOLD}.nii.gz
            #rm -f $BOLD"$suffixBOLD".nii.gz
          endif
         popd
    end
    set suffixBOLD = "${suffixBOLD}_skip"
    #set suffixBOLD = "$suffixBOLD"_skip
    set afterFirstStep = 1
 endif

 if ($faln) then
  echo "[DEBUG]: performing slice-time correction (spm_slice_timing_noui) a.k.a 'frame-align/faln'"
  foreach curr_folder ($zpdbold)
     pushd $curr_folder
      set BOLD = `basename $BOLDbasename .nii.gz`
      echo "[DEBUG]: BOLD = $BOLD"
      echo "[DEBUG]: slice-time correcting $curr_folder/$BOLD$suffixBOLD"
      echo Performing slice time correction $curr_folder/$BOLD$suffixBOLD '('output "$BOLD$suffixBOLD"_faln')' |& tee -a $LF

      if (-e tmp_spm-001.img) rm -f tmp_spm-*
      if ($sliceTimingDim == 3) then
         mri_convert `basename $BOLD$suffixBOLD .nii.gz`.nii.gz -ot spm tmp_spm- |& tee -a $LF
         set numofSlices = `fslval $BOLD$suffixBOLD dim3`
      else
        if ($sliceTimingDim == 2 ) then
            fslswapdim `basename $BOLD$suffixBOLD .nii.gz`.nii.gz x z y tmp_spm.nii.gz
            mri_convert tmp_spm.nii.gz -ot spm tmp_spm- |& tee -a $LF
            rm tmp_spm.nii.gz
            set numofSlices = `fslval $BOLD$suffixBOLD dim2`
          else
            if ($sliceTimingDim == 1) then
                fslswapdim `basename $BOLD$suffixBOLD .nii.gz`.nii.gz y z x tmp_spm.nii.gz
                mri_convert tmp_spm.nii.gz -ot spm tmp_spm- |& tee -a $LF
                rm tmp_spm.nii.gz
                set numofSlices = `fslval $BOLD$suffixBOLD dim1`
            endif
        endif
      endif

      if (! $?sliceOrder) then
        set sliceOrder = "1:2:$numofSlices 2:2:$numofSlices"
        # default to interleaved
      endif

      set MATLAB=`which $_HVD_MATLAB_DIR/bin/matlab`
      echo "[DEBUG]: matlab = $MATLAB"
      if($status) then
        echo "ERROR: could not find matlab"
      exit 1;
      endif

      ################## Start Matlab
      $MATLAB -nojvm -display iconic -nosplash << EOF

       addpath(getenv('_HVD_SPM_DIR'));
       addpath(fullfile(getenv('_HVD_SPM_DIR'), 'toolbox', 'FieldMap'));
       addpath(fullfile(getenv('_HVD_SPM_DIR'), 'Unwarp_updates'));
       addpath(fullfile(getenv('_HVD_CODE_DIR'), 'lib', 'matlab', 'mtt'));

      $spm_matlab_params
      spm_defaults
      P = spm_get('Files','','tmp_spm-???.img');
      middleSlice = [$sliceOrder]; middleSlice = middleSlice(floor( $numofSlices / 2));
      display(['spm_slice_timing_noui(P,[$sliceOrder],' num2str(middleSlice) ',[$TR_vol/$numofSlices  ($TR_vol - $TR_vol/$numofSlices) / ($numofSlices - 1)])']);
      spm_slice_timing_noui(P,[$sliceOrder], middleSlice,[$TR_vol/$numofSlices  ($TR_vol - $TR_vol/$numofSlices) / ($numofSlices - 1)]);
      if exist('matlab_done.touch','file')
        !rm matlab_done.touch
      end
      !touch matlab_done.touch
EOF

      ################## End Matlab
      if (! -e matlab_done.touch) then
         echo Matlab failed to compute slice timing correction. Aborting.
         exit -1;
      else
        rm matlab_done.touch
      endif

     if ($sliceTimingDim == 3) then
       fslmerge -t ${BOLD}${suffixBOLD}_faln atmp_spm-???.img   #skip_faln part where error occurs
       #fslmerge -t $BOLD"$suffixBOLD"_faln atmp_spm-???.img
       rm -f atmp_spm-???.* tmp_spm-???.*
      else
        if ($sliceTimingDim == 2 ) then
             fslmerge -t atmp_spm.nii.gz atmp_spm-???.img
             rm -f atmp_spm-???.* tmp_spm-???.*
             fslswapdim atmp_spm.nii.gz  x z y ${BOLD}${suffixBOLD}_faln
	     #fslswapdim atmp_spm.nii.gz  x z y $BOLD"$suffixBOLD"_faln
             rm -f atmp_spm.nii.gz
            else
            if ($sliceTimingDim == 1) then
                fslmerge -t atmp_spm.nii.gz atmp_spm-???.img
                rm -f atmp_spm-???.* tmp_spm-???.*
                fslswapdim atmp_spm.nii.gz  y z x ${BOLD}${suffixBOLD}_faln
		#fslswapdim atmp_spm.nii.gz  y z x $BOLD"$suffixBOLD"_faln
                rm -f atmp_spm.nii.gz
            endif
        endif
      endif
      if ($cleanup && $afterFirstStep) then
        rm -f ${BOLD}${suffixBOLD}.nii.gz
        #rm -f $BOLD"$suffixBOLD".nii.gz
      endif
     popd
  end
  set suffixBOLD = ${suffixBOLD}_faln 
  #set suffixBOLD = "$suffixBOLD"_faln
  set afterFirstStep = 1


 else
  echo "[DEBUG]: No slice time correction will be performed, but file name will still have "_faln" due to the naming convention of subsequent steps"
  
    foreach curr_folder ($zpdbold)
     pushd $curr_folder

	
	set BOLD = `basename $BOLDbasename .nii.gz`
	echo "[DEBUG]: BOLD = $BOLD"
	echo $curr_folder/$BOLD$suffixBOLD '('output "$BOLD$suffixBOLD"_faln')' |& tee -a $LF
	cp ${BOLD}${suffixBOLD}.nii.gz ${BOLD}${suffixBOLD}_faln.nii.gz

     popd
    end
  set suffixBOLD = ${suffixBOLD}_faln
  set afterFirstStep = 1
 endif

 if ($normalize && (! $spm_normalize)) then
    echo Preparing for one step Motion correction and Target normalization
 endif
 foreach curr_folder ($zpdbold)
    pushd $curr_folder
     set BOLD = `basename $BOLDbasename .nii.gz`
     fslroi $BOLD$suffixBOLD fftdBOLD 10 1 |& tee -a $LF
    popd
 end

 if ($fieldmap_correction) then
  echo "[DEBUG]: field map correction"
  echo Computing field map correction parameters
  /usr/local/freesurfer/dev/bin/epidewarp.fsl --mag $fieldmap/$B0_mag --dph $fieldmap/$B0_phasediff --exf $base_bold/fftdBOLD.nii.gz --tediff $tediff --esp $esp --sigma $sigmamm  --vsm vsm_fftdBOLD.nii.gz --epi  $base_bold/fftdBOLD.nii.gz --epidw $base_bold/dwfftdBOLD.nii.gz --tmpdir fieldmap_epidewarp --nocleanup --nomagexfreg $epidewarp_flags |& tee -a $LF
  set example_func = $base_bold'/dwfftdBOLD.nii.gz'
 else
  set example_func = $base_bold'/fftdBOLD.nii.gz'
 endif


 if(! $?target) then
     set target = $FREESURFER_HOME/fsl/etc/standard/avg152T1_brain
     echo "[DEBUG]: T1 target = $target"
 endif

 if($normalize) then
  echo "[DEBUG]: Beginning normalization"
  if (! $spm_normalize) then
   echo "[DEBUG]: Chose NOT to perform SPM normalization"
   cp $anat/$initial_highres initial_highres.nii.gz

   if ($?initial_highres_uthr) then
    mv initial_highres.nii.gz initial_highres_orig.nii.gz
    echo "[DEBUG]: performing upper-thresholding (fslmaths)" 
    fslmaths initial_highres_orig.nii.gz -uthr $initial_highres_uthr initial_highres.nii.gz
   endif

   if ($slab) then
       echo "[DEBUG]: cp $anat/$slab_initial_highres slab_initial_highres.nii.gz"
       cp $anat/$slab_initial_highres slab_initial_highres.nii.gz
   endif
  endif

  echo "[DEBUG]: cp $example_func example_func.nii.gz"
  cp $example_func example_func.nii.gz

  if($bet_extract) then
    echo "[DEBUG]: cp $anat/$highres highres.nii.gz"
    cp $anat/$highres highres.nii.gz
    echo "[DEBUG]: brain extraction (bet) on highres.nii.gz"
    bet highres bhighres $bet_flags $verbose_flag |& tee -a $LF
  else
    cp $anat/$highres bhighres.nii.gz
    ln -s bhighres.nii.gz highres.nii.gz
  endif
  rm -f target.*
  if (-e "$target".img) then
    cp "$target".img target.img
    cp "$target".hdr target.hdr
   else
    if (-e "$target".nii.gz) then
     cp "$target".nii.gz target.nii.gz
   endif
  endif
  if ($spm_normalize) then
    echo "[DEBUG]: Chose to perform SPM normalization"
    if ($?epitarget) then
      set SPM_TEMPLATE = "VG = '$epitarget'"
     else
      set SPM_TEMPLATE = "VG = fullfile(spm('Dir'),'templates','EPI.mnc');"
      set epitarget = $_HVD_SPM_DIR/templates/EPI.mnc
    endif
    echo "[DEBUG]: converting EPI target '$epitarget' to epitarget.nii.gz"
    mri_convert $epitarget epitarget.nii.gz
    set epitargetnii = `pwd`/epitarget.nii.gz
  endif

  if (! $spm_normalize) then
     echo "[DEBUG]: initial higres = $initial_highres"
     echo initial_highres = $initial_highres |& tee -a $LF
  endif
  echo highres = $highres |& tee -a $LF
  echo example_func = $example_func |& tee -a $LF

  echo Calculating normalization parameters
  echo "[DEBUG]: flirt used = " `which flirt` 
  
  if ($slab) then
      flirt $verbose_flag -ref slab_initial_highres -in example_func -out example_func2slab_initial_highres -omat example_func2slab_initial_highres.mat -cost corratio -dof 6 -schedule $FSL_DIR/etc/flirtsch/sch3Dtrans_3dof -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear |& tee -a $LF
      flirt $verbose_flag -ref initial_highres -in slab_initial_highres -out slab_initial_highres2initial_highres -omat slab_initial_highres2initial_highres.mat -cost corratio -dof 6 -schedule $FSL_DIR/etc/flirtsch/sch3Dtrans_3dof -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear |& tee -a $LF
     #convert_xfm -ref initial_highres -in example_func -omat example_func2initial_highres.mat -concat slab_initial_highres2initial_highres.mat -middlevol slab_initial_highres example_func2initial_highres.mat
     convert_xfm -omat example_func2initial_highres.mat -concat example_func2slab_initial_highres.mat slab_initial_highres2initial_highres.mat |& tee -a $LF
     flirt $verbose_flag -ref initial_highres -in example_func -out example_func2initial_highres -applyxfm -init example_func2initial_highres.mat -interp trilinear |& tee -a $LF
  else
     if (! $spm_normalize) then
       flirt $verbose_flag -ref initial_highres -in example_func -out example_func2initial_highres -omat example_func2initial_highres.mat -cost corratio -dof 6 -schedule $FSL_DIR/etc/flirtsch/sch3Dtrans_3dof -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear |& tee -a $LF
     endif
  endif

  if (! $spm_normalize) then
    convert_xfm -matonly -inverse -omat initial_highres2example_func.mat example_func2initial_highres.mat |& tee -a $LF
    slicer example_func2initial_highres initial_highres -s 1 -x 0.35 sla -x 0.45 slb -x 0.55 slc -x 0.65 sld -y 0.35 sle -y 0.45 slf -y 0.55 slg -y 0.65 slh -z 0.35 sli -z 0.45 slj -z 0.55 slk -z 0.65 sll ; 
    if($matlab_qc_plot) then
        set MATLAB=`which $_HVD_MATLAB_DIR/bin/matlab`
        if($status) then
          echo "ERROR: could not find matlab"
          exit 1;
        endif

        set fsl_preprocess_dir_str = \'$fsl_preprocess_dir\'
        ################## Start Matlab
        $MATLAB -nodesktop -nosplash << EOF

        addpath($fsl_preprocess_dir_str);
        fsl_preprocess_plot_slicer('example_func2initial_highres.jpeg');
        if exist('matlab_done.touch','file')
          !rm matlab_done.touch
        end
        !touch matlab_done.touch	
EOF

        ################## End Matlab
        if (! -e matlab_done.touch) then
           echo Matlab fails to draw fsl_preprocess registration slicer plots. Aborting.
           exit -1;
        else
           rm matlab_done.touch
        endif
    else 
	convert -colors 100 +append sla slb slc sld sle slf slg slh sli slj slk sll example_func2initial_highres.gif ; 
    endif
    /bin/rm -f sla slb slc sld sle slf slg slh sli slj slk sll |& tee -a $LF

    flirt $verbose_flag -ref bhighres -in initial_highres -out initial_highres2bhighres -omat initial_highres2bhighres.mat -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear |& tee -a $LF

    convert_xfm -matonly -inverse -omat bhighres2initial_highres.mat initial_highres2bhighres.mat |& tee -a $LF

    slicer initial_highres2bhighres bhighres -s 1 -x 0.35 sla -x 0.45 slb -x 0.55 slc -x 0.65 sld -y 0.35 sle -y 0.45 slf -y 0.55 slg -y 0.65 slh -z 0.35 sli -z 0.45 slj -z 0.55 slk -z 0.65 sll ; 

    if($matlab_qc_plot) then
        set MATLAB=`which $_HVD_MATLAB_DIR/bin/matlab`
        if($status) then
          echo "ERROR: could not find matlab"
          exit 1;
        endif

        set fsl_preprocess_dir_str = \'$fsl_preprocess_dir\'
        ################## Start Matlab
        $MATLAB -nodesktop -nosplash << EOF

        addpath($fsl_preprocess_dir_str);
        fsl_preprocess_plot_slicer('initial_highres2bhighres.jpeg');
        if exist('matlab_done.touch','file')
          !rm matlab_done.touch
        end
        !touch matlab_done.touch
EOF

        ################## End Matlab
        if (! -e matlab_done.touch) then
           echo Matlab fails to draw fsl_preprocess registration slicer plots. Aborting.
           exit -1;
        else
           rm matlab_done.touch
        endif
    else
        convert -colors 100 +append sla slb slc sld sle slf slg slh sli slj slk sll initial_highres2bhighres.gif; 
    endif
    /bin/rm -f sla slb slc sld sle slf slg slh sli slj slk sll |& tee -a $LF

    convert_xfm -ref bhighres -in example_func -omat example_func2bhighres.mat -concat initial_highres2bhighres.mat -middlevol initial_highres example_func2initial_highres.mat |& tee -a $LF

    flirt $verbose_flag -ref bhighres -in example_func -out example_func2bhighres -applyxfm -init example_func2bhighres.mat -interp trilinear |& tee -a $LF

    convert_xfm -matonly -inverse -omat bhighres2example_func.mat example_func2bhighres.mat |& tee -a $LF

    slicer example_func2bhighres bhighres -s 1 -x 0.35 sla -x 0.45 slb -x 0.55 slc -x 0.65 sld -y 0.35 sle -y 0.45 slf -y 0.55 slg -y 0.65 slh -z 0.35 sli -z 0.45 slj -z 0.55 slk -z 0.65 sll ; 

    if($matlab_qc_plot) then
        set MATLAB=`which $_HVD_MATLAB_DIR/bin/matlab`
        if($status) then
          echo "ERROR: could not find matlab"
          exit 1;
        endif

        set fsl_preprocess_dir_str = \'$fsl_preprocess_dir\'
        ################## Start Matlab
        $MATLAB -nodesktop -nosplash << EOF

        addpath($fsl_preprocess_dir_str);
        fsl_preprocess_plot_slicer('example_func2bhighres.jpeg');
        if exist('matlab_done.touch','file') 
          !rm matlab_done.touch
        end
        !touch matlab_done.touch
EOF

        ################## End Matlab
        if (! -e matlab_done.touch) then
           echo Matlab fails to draw fsl_preprocess registration slicer plots. Aborting.
           exit -1;
        else
           rm matlab_done.touch
        endif
    else
        convert -colors 100 +append sla slb slc sld sle slf slg slh sli slj slk sll example_func2bhighres.gif ;
    endif
    /bin/rm -f sla slb slc sld sle slf slg slh sli slj slk sll |& tee -a $LF
  endif

  flirt $verbose_flag -ref target -in bhighres -out bhighres2target -omat bhighres2target.mat -cost corratio -dof 12 -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -interp trilinear |& tee -a $LF

  convert_xfm -matonly -inverse -omat target2bhighres.mat bhighres2target.mat |& tee -a $LF

  slicer bhighres2target target -s 1 -x 0.35 sla -x 0.45 slb -x 0.55 slc -x 0.65 sld -y 0.35 sle -y 0.45 slf -y 0.55 slg -y 0.65 slh -z 0.35 sli -z 0.45 slj -z 0.55 slk -z 0.65 sll ; 
  if($matlab_qc_plot) then
        set MATLAB=`which $_HVD_MATLAB_DIR/bin/matlab`
        if($status) then
          echo "ERROR: could not find matlab"
          exit 1;
        endif

        set fsl_preprocess_dir_str = \'$fsl_preprocess_dir\'
        ################## Start Matlab
        $MATLAB -nodesktop -nosplash << EOF

        addpath($fsl_preprocess_dir_str);
        fsl_preprocess_plot_slicer('bhighres2target.jpeg');
        if exist('matlab_done.touch','file')
          !rm matlab_done.touch
        end
        !touch matlab_done.touch
EOF

        ################## End Matlab
        if (! -e matlab_done.touch) then
           echo Matlab fails to draw fsl_preprocess registration slicer plots. Aborting.
           exit -1;
        else
           rm matlab_done.touch
        endif
  else
	convert -colors 100 +append sla slb slc sld sle slf slg slh sli slj slk sll bhighres2target.gif ;
  endif
  /bin/rm -f sla slb slc sld sle slf slg slh sli slj slk sll |& tee -a $LF


 if (! $spm_normalize) then
  convert_xfm -ref target -in example_func -omat example_func2target.mat -concat bhighres2target.mat -middlevol bhighres example_func2bhighres.mat |& tee -a $LF

  flirt $verbose_flag -ref target -in example_func -out example_func2target -applyxfm -init example_func2target.mat -interp trilinear |& tee -a $LF

  convert_xfm -matonly -inverse -omat target2example_func.mat example_func2target.mat |& tee -a $LF

  slicer example_func2target target -s 1 -x 0.35 sla -x 0.45 slb -x 0.55 slc -x 0.65 sld -y 0.35 sle -y 0.45 slf -y 0.55 slg -y 0.65 slh -z 0.35 sli -z 0.45 slj -z 0.55 slk -z 0.65 sll ; 
  if($matlab_qc_plot) then
        set MATLAB=`which $_HVD_MATLAB_DIR/bin/matlab`
        if($status) then
          echo "ERROR: could not find matlab"
          exit 1;
        endif

        set fsl_preprocess_dir_str = \'$fsl_preprocess_dir\'
        ################## Start Matlab
        $MATLAB -nodesktop -nosplash << EOF

        addpath($fsl_preprocess_dir_str);
        fsl_preprocess_plot_slicer('example_func2target.jpeg');
        if exist('matlab_done.touch','file')
          !rm matlab_done.touch
        end
        !touch matlab_done.touch
EOF

        ################## End Matlab
        if (! -e matlab_done.touch) then
           echo Matlab fails to draw fsl_preprocess registration slicer plots. Aborting.
           exit -1;
        else
           rm matlab_done.touch
        endif
  else
	convert -colors 100 +append sla slb slc sld sle slf slg slh sli slj slk sll example_func2target.gif ; 
  endif
  /bin/rm -f sla slb slc sld sle slf slg slh sli slj slk sll |& tee -a $LF

  flirt $verbose_flag -ref target -in example_func -out example_func2target -applyxfm -init example_func2target.mat -interp trilinear |& tee -a $LF
  endif

  if($bet_extract) then
    cp bhighres2target.nii.gz $anat/`basename $highres .nii.gz`_atl_brain.nii.gz
    flirt $verbose_flag -ref target -in highres -out highres2target -applyxfm -init bhighres2target.mat |& tee -a $LF

    cp highres2target.nii.gz $anat/`basename $highres .nii.gz`_atl.nii.gz
   else
    cp bhighres2target.nii.gz $anat/`basename $highres .nii.gz`_atl.nii.gz
  endif

  flirt $verbose_flag -ref target -in highres -out highres1112target -init bhighres2target.mat -applyisoxfm 1 -forcescaling |& tee -a $LF
  cp highres1112target.nii.gz $anat/`basename $highres .nii.gz`_atl111.nii.gz

 endif


 if (! -e $movement) then
     mkdir -p $movement
 endif
 echo -n > mc.par
 echo -n > mc_abs.rms
 echo -n > mc_rel.rms
 if ($normalize && (! $fieldmap_correction) && (! $spm_normalize)) then
    set temp_suffix = "_mc_atl"
 else
    set temp_suffix = "_mc"
 endif
 foreach curr_folder ($zpdbold)
    pushd $curr_folder
     set BOLD = `basename $BOLDbasename .nii.gz`
     @ numof_tps = `fslnvols $BOLD` - $skip
     echo Performing motion correction on $curr_folder/$BOLD$suffixBOLD relative to session `basename $base_bold` '('output $BOLD"$suffixBOLD""$temp_suffix"')' |& tee -a $LF
     fslmerge -t tmp_tdBOLD $example_func $BOLD$suffixBOLD |& tee -a $LF
     if ($normalize && ! $fieldmap_correction && ! $spm_normalize) then
          if (-d tmp_tdBOLD_mc.mat) rm -rf tmp_tdBOLD_mc.mat
          mcflirt -in tmp_tdBOLD  -out tmp_tdBOLD_mc -mats -plots -refvol 0 -rmsrel -rmsabs $mc_flags |& tee -a $LF

          mv tmp_tdBOLD_mc.par  $BOLD"$suffixBOLD""$temp_suffix".par
          mv tmp_tdBOLD_mc_rel.rms  $BOLD"$suffixBOLD""$temp_suffix"_rel.rms
          mv tmp_tdBOLD_mc_abs.rms  $BOLD"$suffixBOLD""$temp_suffix"_abs.rms

          pushd tmp_tdBOLD_mc.mat
           fslsplit ../tmp_tdBOLD
           @ index = 1
           while ($index <= $numof_tps)
                convert_xfm -omat xfm.mat -concat ../../example_func2target.mat `echo $index | awk '{printf("MAT_%04d",$1);}'`
                flirt $verbose_flag -ref ../../target -in `echo $index | awk '{printf("vol%04d",$1);}'`  -out `echo $index | awk '{printf("vol%04d_mc_atl",$1);}'` -applyxfm -init xfm.mat -interp trilinear |& tee -a $LF
                @ index = $index + 1
           end
           fslmerge -t ../$BOLD"$suffixBOLD""$temp_suffix" vol????_mc_atl*

           echo $BOLD"$suffixBOLD""$temp_suffix"
           rm vol*
          popd
          set outdir_tmp = ""
          while (-e  $BOLD"$suffixBOLD""$temp_suffix".mat"$outdir_tmp")
           set outdir_tmp = $outdir_tmp"+"
          end
          mv tmp_tdBOLD_mc.mat  $BOLD"$suffixBOLD""$temp_suffix".mat"$outdir_tmp"
          if ($cleanup && $afterFirstStep) then
            rm -f $BOLD"$suffixBOLD".nii.gz
          endif
     else
          mcflirt -in tmp_tdBOLD -out $BOLD"$suffixBOLD""$temp_suffix" -plots -refvol 0 -rmsrel -rmsabs $mc_flags |& tee -a $LF
     endif
     tail -n $numof_tps `basename $BOLD"$suffixBOLD""$temp_suffix" .nii.gz`.par >> ../mc.par

     ## create a file for fcMRI_preproc

     tail -n $numof_tps `basename $BOLD"$suffixBOLD""$temp_suffix" .nii.gz`.par | awk 'BEGIN {n=0; init=0;} ($1 !~/#/) { ncol = NF; init = 1; } (init == 1 && $1 !~/#/) { if (NF != ncol) { print "format error"; exit -1;} for (j=1;j<=ncol;j++) data[n,int((j+2)%6) + 1] = $j; n++;} END { for (i = 0; i < n; i++) { printf("%d", i+1); for (j = 1;j <=ncol; j++) printf ("%10.6f", data[i,j]); printf("%10.6f\n",1);}}' > $movement/$BOLD"$suffixBOLD"_mc.dat

     tail -n $numof_tps `basename $BOLD"$suffixBOLD""$temp_suffix" .nii.gz`.par | awk 'BEGIN {n=0; init=0;} ($1 !~/#/) { ncol = NF; if (init == 0) {printf ("%d",1); for (j = 1; j <= ncol; j++) { printf("%10.6f", 0)}; printf("%10.6f\n",1); }; init = 1; } (init == 1 && $1 !~/#/) { if (NF != ncol) { print "format error"; exit -1;} for (j=1;j<=ncol;j++) data[n,int((j+2)%6)+1] = $j; n++;} END { for (i = 1; i < n; i++) { printf("%d", i+1); for (j = 1;j <=ncol; j++) printf ("%10.6f", data[i,j] - data[i-1,j]); printf("%10.6f\n", 0);}}' > $movement/$BOLD"$suffixBOLD"_mc.ddat

     tail -n $numof_tps `basename $BOLD"$suffixBOLD""$temp_suffix" .nii.gz`.par | awk 'BEGIN {n=0; init=0;} ($1 !~/#/) { ncol = NF; if (init == 0) {for (j = 1; j <= ncol; j++) { data_average[j] = 0;}; }; init = 1; } (init == 1 && $1 !~/#/) { if (NF != ncol) { print "format error"; exit -1;} for (j=1;j<=ncol;j++) {data[n,int((j+2)%6)+1] = $j; data_average[int((j+2)%6)+1] = (data[n,int((j+2)%6+1)] + data_average[int((j+2)%6+1)]*(n+1) ) / (n+2);} n++;} END { for (i = 0; i < n; i++) { printf("%d", i+1); for (j = 1;j <=ncol; j++) printf ("%10.6f", data[i,j] - data_average[j]); printf("%10.6f\n", 1);}}' > $movement/$BOLD"$suffixBOLD"_mc.rdat

     tail -n $numof_tps `basename $BOLD"$suffixBOLD""$temp_suffix" .nii.gz`_abs.rms >> ../mc_abs.rms
     @ numof_tps = $numof_tps - 1
     tail -n $numof_tps `basename $BOLD"$suffixBOLD""$temp_suffix" .nii.gz`_rel.rms >> ../mc_rel.rms
     @ numof_tps = $numof_tps + 1
     if ((! $normalize )|| $fieldmap_correction || $spm_normalize) then
        fslroi ${BOLD}${suffixBOLD}${temp_suffix} tmp_mtdBOLD 1 $numof_tps |& tee -a $LF
        #fslroi $BOLD"$suffixBOLD""$temp_suffix" tmp_mtdBOLD 1 $numof_tps |& tee -a $LF
        /bin/mv tmp_mtdBOLD.nii.gz $BOLD"$suffixBOLD""$temp_suffix".nii.gz
        if ($cleanup && $afterFirstStep) then
            rm -f $BOLD"$suffixBOLD".nii.gz
        endif
     endif
     /bin/rm tmp_*BOLD*
    popd
 end
 set suffixBOLD = ${suffixBOLD}${temp_suffix}
 #set suffixBOLD = "$suffixBOLD""$temp_suffix"
 set afterFirstStep = 1
 unset temp_suffix

 if ($fieldmap_correction) then
  echo Peforming field map correction

  foreach curr_folder ($zpdbold)
     pushd $curr_folder
      echo Processing folder $curr_folder |& tee -a $LF
      set BOLD = `basename $BOLDbasename .nii.gz` |& tee -a $LF
     popd
     echo dewarping $BOLD$suffixBOLD |& tee -a $LF
     pushd fieldmap_epidewarp/epi-split/
      rm vol*
      fslsplit ../../$curr_folder/$BOLD$suffixBOLD |& tee -a $LF
     popd

     foreach vol (`ls fieldmap_epidewarp/epi-split/vol*.nii.gz`)
         fugue -i $vol -u fieldmap_epidewarp/epi-split/`basename $vol .nii.gz`_dw.nii.gz --loadshift=vsm_fftdBOLD.nii.gz --mask=fieldmap_epidewarp/brain.nii.gz |& tee -a $LF
     end
     fslmerge -t $curr_folder/$BOLD"$suffixBOLD"_dw fieldmap_epidewarp/epi-split/vol0*_dw.nii.gz |& tee -a $LF
     if ($cleanup && afterFirstStep) then
        rm -f $curr_folder/$BOLD"$suffixBOLD".nii.gz
     endif
  end

  set suffixBOLD = ${suffixBOLD}_dw
  #set suffixBOLD = "$suffixBOLD"_dw
  set afterFirstStep = 1

  if ($normalize && (! $spm_normalize) then
     echo Normalizing functional data
     flirt $verbose_flag -ref target -in example_func -out example_func2target -applyxfm -init example_func2target.mat -interp trilinear |& tee -a $LF

     foreach curr_folder ($zpdbold)
      pushd $curr_folder
       set BOLD = `basename $BOLDbasename .nii.gz`
       echo Normalizing $curr_folder/$BOLD$suffixBOLD '('output $BOLD"$suffixBOLD"_atl')'
       flirt -ref ../target -in $BOLD$suffixBOLD -out $BOLD"$suffixBOLD"_atl -applyxfm -init ../example_func2target.mat -interp trilinear
       if ($cleanup && $afterFirstStep) then
        rm -f $BOLD"$suffixBOLD".nii.gz
       endif
      popd
     end
     set suffixBOLD = ${suffixBOLD}_atl
     #set suffixBOLD = "$suffixBOLD"_atl
     set afterFirstStep = 1
  endif
 endif

 if ($spm_normalize && ($normalize || $epi_normalize)) then
    foreach curr_folder ($zpdbold)
     pushd $curr_folder
      set BOLD = `basename $BOLDbasename .nii.gz`
      echo Performing spm_normalization $curr_folder/$BOLD$suffixBOLD '('output "$BOLD$suffixBOLD"_atl')' |& tee -a $LF

      if (-e tmp_spm-001.img) rm -f tmp_spm-*
      mri_convert `basename $BOLD$suffixBOLD .nii.gz`.nii.gz -ot spm tmp_spm- |& tee -a $LF
      mri_convert $example_func -ot spm example_func- |& tee -a $LF

      set MATLAB=`which $_HVD_MATLAB_DIR/bin/matlab`
      if($status) then
        echo "ERROR: could not find matlab"
      exit 1;
      endif

      ################## Start Matlab
      $MATLAB -nojvm -display iconic -nosplash << EOF
      %warning off

       addpath(getenv('_HVD_SPM_DIR'));
       addpath(fullfile(getenv('_HVD_SPM_DIR'), 'toolbox', 'FieldMap'));
       addpath(fullfile(getenv('_HVD_SPM_DIR'), 'Unwarp_updates'));
       addpath(fullfile(getenv('_HVD_CODE_DIR'), 'lib', 'matlab', 'mtt'));

      $spm_matlab_params
      spm_defaults
      P = spm_get('Files','','tmp_spm-???.img');

      meanf = spm_get('Files','','example_func-001.img');
      Vm = spm_vol(meanf);
      V = spm_vol(P); % Get header information for images

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Normalization
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      dafaults.normalise.write.vox = [2 2 2];
      defaults.normalise.write.interp = 7;
      defaults.normalise.write.wrap = [0 1 0];
      defaults.normalise.write.bb = [[-90 -126 -72];[ 90 90 108]];

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Estimate unwarping parameters
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      matname = [spm_str_manip(Vm.fname, 'sd') '_sn.mat'];
      $SPM_TEMPLATE
      params = spm_normalise(VG, Vm, matname, '','', ...
                             defaults.normalise.estimate);
      snMask = spm_write_sn(V,params,defaults.normalise.write,'mask');
      disp('Determining noralization parameters');
      spm_write_sn(Vm,params,defaults.normalise.write, snMask);

      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      % Write normalized
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      disp('Writing normalized')
      for ii=1:length(V),
          spm_write_sn(V(ii),params,defaults.normalise.write,snMask);
      end

      if exist('matlab_done.touch','file')
        !rm matlab_done.touch
      end
      !touch matlab_done.touch
EOF

      ################## End Matlab
      if (! -e matlab_done.touch) then
         echo Matlab failed to normalize to EPI template. Aborting.
         exit -1;
      else
        rm matlab_done.touch
      endif

      fslmerge -t wtmp_spm.nii.gz wtmp_spm-???.img
      # mri_convert -it spm wtmp_spm- -ot nii wtmp_spm.nii.gz
      fslswapdim wtmp_spm.nii.gz -x y z wtmp_spm_sd.nii.gz
      fslmaths wtmp_spm_sd.nii.gz -nan ${BOLD}${suffixBOLD}_atl
      #fslmaths wtmp_spm_sd.nii.gz -nan $BOLD"$suffixBOLD"_atl
      if ($cleanup && $afterFirstStep) then
        rm -f $BOLD"$suffixBOLD".nii.gz
      endif
      mv example_func-001_sn.mat $BOLD"$suffixBOLD"_sn.mat
      # mri_convert wexample_func-001.img $boldfolder/example_func2target.nii.gz
      fslmaths wexample_func-001.img -nan wextmp.nii.gz
      fslswapdim wextmp.nii.gz -x y z $boldfolder/example_func2target.nii.gz
      rm -f wextmp.nii.gz

      if ($normalize) then
       if ($bet_extract) then
         slicer $boldfolder/example_func2target.nii.gz $anat/`basename $highres .nii.gz`_atl_brain.nii.gz -s 1 -x 0.35 sla -x 0.45 slb -x 0.55 slc -x 0.65 sld -y 0.35 sle -y 0.45 slf -y 0.55 slg -y 0.65 slh -z 0.35 sli -z 0.45 slj -z 0.55 slk -z 0.65 sll ; 
         if($matlab_qc_plot) then
           set MATLAB=`which $_HVD_MATLAB_DIR/bin/matlab`
           if($status) then
             echo "ERROR: could not find matlab"
             exit 1;
           endif

	   set fsl_preprocess_dir_str = \'$fsl_preprocess_dir\'
	   ################## Start Matlab
	   $MATLAB -nodesktop -nosplash << EOF

	   addpath($fsl_preprocess_dir_str);
           fsl_preprocess_plot_slicer('$boldfolder/example_func2bhighres.jpeg');
           if exist('matlab_done.touch','file')
             !rm matlab_done.touch
           end
           !touch matlab_done.touch
EOF

           ################## End Matlab
	   if (! -e matlab_done.touch) then
	      echo Matlab fails to draw fsl_preprocess registration slicer plots. Aborting.
	      exit -1;
	   else
	      rm matlab_done.touch
           endif
         else
	   convert -colors 100 +append sla slb slc sld sle slf slg slh sli slj slk sll $boldfolder/example_func2bhighres.gif ; 
         endif
         /bin/rm -f sla slb slc sld sle slf slg slh sli slj slk sll |& tee -a $LF
      else
         slicer $boldfolder/example_func2target.nii.gz $anat/`basename $highres .nii.gz`_atl.nii.gz -s 1 -x 0.35 sla -x 0.45 slb -x 0.55 slc -x 0.65 sld -y 0.35 sle -y 0.45 slf -y 0.55 slg -y 0.65 slh -z 0.35 sli -z 0.45 slj -z 0.55 slk -z 0.65 sll ; 
	 if($matlab_qc_plot) then
	   set MATLAB=`which $_HVD_MATLAB_DIR/bin/matlab`
	   if($status) then
	     echo "ERROR: could not find matlab"
	     exit 1;
	   endif

	   set fsl_preprocess_dir_str = \'$fsl_preprocess_dir\'
	   ################## Start Matlab
	   $MATLAB -nodesktop -nosplash << EOF

	   addpath($fsl_preprocess_dir_str);
	   fsl_preprocess_plot_slicer('$boldfolder/example_func2bhighres.jpeg');
	   if exist('matlab_done.touch','file')
             !rm matlab_done.touch
           end
           !touch matlab_done.touch
EOF

           ################## End Matlab
           if (! -e matlab_done.touch) then
             echo Matlab fails to draw fsl_preprocess registration slicer plots. Aborting.
             exit -1;
           else
             rm matlab_done.touch
           endif
       else
	   convert -colors 100 +append sla slb slc sld sle slf slg slh sli slj slk sll $boldfolder/example_func2bhighres.gif ; 
       endif
       /bin/rm -f sla slb slc sld sle slf slg slh sli slj slk sll |& tee -a $LF
    endif

       if ($spm_normalize) then
         slicer $boldfolder/example_func2target.nii.gz $epitargetnii -s 1 -x 0.35 sla -x 0.45 slb -x 0.55 slc -x 0.65 sld -y 0.35 sle -y 0.45 slf -y 0.55 slg -y 0.65 slh -z 0.35 sli -z 0.45 slj -z 0.55 slk -z 0.65 sll ; 
         if($matlab_qc_plot) then
        set MATLAB=`which $_HVD_MATLAB_DIR/bin/matlab`
        if($status) then
          echo "ERROR: could not find matlab"
          exit 1;
        endif

        set fsl_preprocess_dir_str = \'$fsl_preprocess_dir\'
        ################## Start Matlab
        $MATLAB -nodesktop -nosplash << EOF

        addpath($fsl_preprocess_dir_str);
        fsl_preprocess_plot_slicer('$boldfolder/example_func2target.jpeg');
        if exist('matlab_done.touch','file')
          !rm matlab_done.touch
        end
        !touch matlab_done.touch
EOF

        ################## End Matlab
        if (! -e matlab_done.touch) then
           echo Matlab fails to draw fsl_preprocess registration slicer plots. Aborting.
           exit -1;
        else
           rm matlab_done.touch
        endif
    else
	convert -colors 100 +append sla slb slc sld sle slf slg slh sli slj slk sll $boldfolder/example_func2target.gif ; 
    endif
    /bin/rm -f sla slb slc sld sle slf slg slh sli slj slk sll |& tee -a $LF
        else
         slicer $boldfolder/example_func2target.nii.gz $target -s 1 -x 0.35 sla -x 0.45 slb -x 0.55 slc -x 0.65 sld -y 0.35 sle -y 0.45 slf -y 0.55 slg -y 0.65 slh -z 0.35 sli -z 0.45 slj -z 0.55 slk -z 0.65 sll ; 
                  if($matlab_qc_plot) then
        set MATLAB=`which $_HVD_MATLAB_DIR/bin/matlab`
        if($status) then
          echo "ERROR: could not find matlab"
          exit 1;
        endif 

        set fsl_preprocess_dir_str = \'$fsl_preprocess_dir\'
        ################## Start Matlab
        $MATLAB -nodesktop -nosplash << EOF

        addpath($fsl_preprocess_dir_str);
        fsl_preprocess_plot_slicer('$boldfolder/example_func2target.jpeg');
        if exist('matlab_done.touch','file')
          !rm matlab_done.touch
        end
        !touch matlab_done.touch
EOF

        ################## End Matlab
        if (! -e matlab_done.touch) then
           echo Matlab fails to draw fsl_preprocess registration slicer plots. Aborting.
           exit -1;
        else
           rm matlab_done.touch
        endif
    else
  	convert -colors 100 +append sla slb slc sld sle slf slg slh sli slj slk sll $boldfolder/example_func2target.gif ; 
    endif
    /bin/rm -f sla slb slc sld sle slf slg slh sli slj slk sll |& tee -a $LF
       endif
      endif
      rm -f wtmp_spm-???.* tmp_spm-???.* wtmp_spm.nii.gz wtmp_spm_sd.nii.gz example_func-???.* wexample_func-???.*
     popd
  end
  set suffixBOLD = ${suffixBOLD}_atl
  #set suffixBOLD = "$suffixBOLD"_atl
  set afterFirstStep = 1
 endif
popd

goto finish;

exit 0;

################################################
finish:
 ## PRINT REPORT
 ##instead of set terminal png picsize <x> <y> use terminal png size <x>,<y>
 pushd $boldfolder

 if($matlab_qc_plot) then
          
      set MATLAB=`which $_HVD_MATLAB_DIR/bin/matlab`
      if($status) then
        echo "ERROR: could not find matlab"
        exit 1;
      endif

      set fsl_preprocess_dir_str = \'$fsl_preprocess_dir\'
      ################## Start Matlab
      $MATLAB -nodesktop -nosplash << EOF

      addpath($fsl_preprocess_dir_str);
      fsl_preprocess_plot_motion;
      if exist('matlab_done.touch','file')
        !rm matlab_done.touch
      end
      !touch matlab_done.touch
EOF

      ################## End Matlab
      if (! -e matlab_done.touch) then
         echo Matlab fails to draw fsl_preprocess motion plots. Aborting.
         exit -1;
      else
        rm matlab_done.touch
      endif
 else
    echo 'set output "mc_rot.png"; set terminal png size 320,200;set title "MCFLIRT estimated rotations (radians)"; plot "mc.par" using 1 title "x" with lines, "mc.par" using 2 title "y" with lines, "mc.par" using 3 title "z" with lines' | /usr/bin/gnuplot
    echo 'set output "mc_trans.png"; set terminal png size 320,200; set title "MCFLIRT estimated translations (mm)"; plot "mc.par" using 4 title "x" with lines, "mc.par" using 5 title "y" with lines, "mc.par" using 6 title "z" with lines' | /usr/bin/gnuplot
    echo 'set output "mc_disp.png"; set terminal png size 320,200; set title "MCFLIRT estimated mean displacement (mm)"; plot "mc_abs.rms" using 1 title "absolute" with lines, "mc_rel.rms" using 1 title "relative" with lines' | /usr/bin/gnuplot
    convert mc_rot.png mc_rot.gif; rm mc_rot.png
    convert mc_trans.png mc_trans.gif; rm mc_trans.png
    convert mc_disp.png mc_disp.gif; rm mc_disp.png
 endif
 date |& tee -a $LF
 echo "fsl_preprocess.sh done" |& tee -a $LF

 if (! $?qc_folder) then
   set qc_folder = 'qc'
 endif
 mkdir -p $root/$subject/$qc_folder
 mv *.gif $root/$subject/$qc_folder
 mv *.jpeg $root/$subject/$qc_folder
 mv *.mat $root/$subject/$qc_folder
 mv *.nii* $root/$subject/$qc_folder
 mv *.rms $root/$subject/$qc_folder
 mv *.par $root/$subject/$qc_folder
 mv $LF $root/$subject/$qc_folder
 popd

 pushd  $root/$subject/$qc_folder

  set date_time = "`date +%F` `date +%T`"
  touch index.html
  echo "<HTML><TITLE>Preprocessing Report - Subject "$subject"</TITLE><BODY>" > index.html

  cat $FSL_PREPROCESS | awk -v date_time_str="$date_time" 'BEGIN{prt=0}{if($1 == "ENDMCREPORT") prt =0;  gsub("\\$DATE\\$",date_time_str,$0);  gsub("\\$PWD\\$","file: '`pwd`'/index.html",$0);gsub("\\$SUBJECT\\$","'$subject'",$0);gsub("\\$TARGET\\$","'$target'",$0);if(prt) print $0; if($1 == "BEGINMCREPORT") prt = 1;}' >> index.html

  if ($normalize || $epi_normalize) then
   if ($spm_normalize) then
    cat $FSL_PREPROCESS | awk -v date_time_str="$date_time" 'BEGIN{prt=0}{if($1 == "ENDSPMNORMREPORT") prt =0;  gsub("\\$DATE\\$",date_time_str,$0);  gsub("\\$PWD\\$","file: '`pwd`'/index.html",$0);gsub("\\$SUBJECT\\$","'$subject'",$0);gsub("\\$TARGET\\$","'$target'",$0);gsub("\\$EPITARGET\\$","'$epitargetnii'",$0);if(prt) print $0; if($1 == "BEGINSPMNORMREPORT") prt = 1;}' >> index.html
   else
    cat $FSL_PREPROCESS | awk -v date_time_str="$date_time" 'BEGIN{prt=0}{if($1 == "ENDNORMREPORT") prt =0;  gsub("\\$DATE\\$",date_time_str,$0);  gsub("\\$PWD\\$","file: '`pwd`'/index.html",$0);gsub("\\$SUBJECT\\$","'$subject'",$0);gsub("\\$TARGET\\$","'$target'",$0);if(prt) print $0; if($1 == "BEGINNORMREPORT") prt = 1;}' >> index.html
   endif
  endif
  echo "</BODY></HTML>" >> index.html

  
  if($matlab_qc_plot) then
	sed 's/gif/jpeg/g' index.html > tmp.html
        mv tmp.html index.html
  endif

   popd

 ##
exit 0;
################################################

parse_args:

set cmdline = ($argv);
while( $#argv != 0 )

  set flag = $argv[1]; shift;
  switch($flag)

    case "--subject":
    case "-s":
      if ( $#argv == 0) goto arg1err;
      set subject = `basename $argv[1]`; shift;
      breaksw

    case "--script":
      if ( $#argv == 0) goto arg1err;
      set script = $argv[1]; shift;
      if(! -e $script) then
        echo "ERROR: cannot find script file ($script)"
        exit 1;
      endif
      source $script
      breaksw

    case "--slab":
      set slab = 1;
      breaksw

    case "--target":
      if ( $#argv == 0) goto arg1err;
      set target = $argv[1]; shift;
      breaksw

    case "--epitarget":
      if ( $#argv == 0) goto arg1err;
      set epitarget = $argv[1]; shift;
      breaksw

    case "--nobet":
      set bet_extract = 0;
      breaksw

    case "--nofaln":
      set faln = 0;
      breaksw;

    case "--fslmpr":
      set spm_normalize = 0;
      breaksw

    case "--spmepi":
      set spm_normalize = 1;
      set epi_normalize = 1;
      breaksw

    case "--nonorm":
      set normalize = 0;
      breaksw

    case "--base":
    case "-b":
      if ( $#argv == 0) goto arg1err;
      set root = $argv[1]; shift;
      breaksw

    case "--dewarp":
      set fieldmap_correction = 1;
      breaksw;

    case "--nocleanup":
      set cleanup = 0;
      breaksw;

    case "--matlab_qc_plot":
      set matlab_qc_plot = 1;
      breaksw;

    case "--verbose":
      set verbose_flag = "-v";
      breaksw;

    default:
      echo ERROR: Flag $flag unrecognized.
      echo $cmdline
      exit 1
      breaksw
  endsw

end

goto parse_args_return;

################################################

check_params:

if($#subject == 0) then
  echo "ERROR: subject folder not specified"
  exit 1;
endif

if(! -e $root) then
  echo "ERROR: cannot find root folder ($root)"
  exit 1;
endif

if (! -e $root/$subject) then
  echo "ERROR: cannot find folder " $subject
  exit -1;
endif

if (! $?script) then
if (! -e $root/$subject/scripts/"$subject".params) then
  echo "ERROR: cannot find script file ($subject/scripts/"$subject".params). Attempting with defaults."
 else
  source $root/$subject/scripts/"$subject".params
endif
endif

set boldfolder = "$root"/"$subject"/bold
if ($fieldmap_correction) then
	set fieldmap = "$root"/"$subject"/fieldmap
endif
#set anat3d = "$root"/"$subject"/3danat
if ($normalize) then
    set anat = "$root"/"$subject"/anat
    if(! -e $anat) then
        echo "ERROR: cannot find anat folder in $subject"
        exit 1;
    endif

    if ($fieldmap_correction) then
            if(! -e $fieldmap) then
                echo "ERROR: cannot find fieldmap folder in $subject"
                exit 1;
            endif
    endif
endif

set movement = "$root"/"$subject"/movement

if(! -e $boldfolder) then
    echo "ERROR: cannot find bold folder in $subject"
    exit 1;
endif


setenv LF $root/$subject/`basename $FSL_PREPROCESS .sh`$$".log"

goto check_params_return;


################################################
arg1err:
  echo "ERROR: flag $flag requires one argument"
  exit 1
################################################

usage_exit:
  echo ""
  echo "USAGE: fsl_preprocess.sh"
  echo ""
  echo "Inputs"
  echo "  -s, --subject folder  : subject's folder"
  echo "  -b, --base folder     : full path to subject's folder"
  echo "                         [if not specified defaults to current path]"
  echo "  --script fname        : preprocessing configuration script"
  echo "  --nofaln              : do not perform frame align (slice timing correction)"
  echo "  --dewarp              : compute field map dewarping"
  echo ""
  echo "  --spmepi              : normalize using SPM epi template (default)"
  echo "                          [if used in combination with --nonorm it will still normalize but BOLD runs only"
  echo ""
  echo "  --fslmpr              : normalize using FSL, 3D T1, and target atlas"
  echo "  --target atlasfile    : normalize to target atlas (default MNI152)"
  echo "  --epitarget atlasfile : normalize to EPI target atlas (defult SPM's EPI.mnc)"
  echo "  --slab                : use epi_slab->epi_t1w_slab->epi_t1_wholeBrain->T1_MPRAGE->TARGET_ATLAS"
  echo "  --nonorm              : do not perform normalization"
  echo "  --nobet               : do not perform brain extraction"
  echo "  "
  echo "  --verbose             : verbose text output"
  echo "  --nocleanup           : do not remove intermediate files"
  echo "  --matlab_qc_plot      : use matlab for qc plots instead of gnuplot etc"
  echo "  "
  echo "  -h, --help"
  echo "  -v, --version"

  if(! $printhelp) exit 1;

  echo $VERSION

  cat $FSL_PREPROCESS | awk 'BEGIN{prt=0}{if(prt) print $0; if($1 == "BEGINHELP") prt = 1 }'

exit 1;

##### report ######
BEGINMCREPORT

<hr><CENTER>
<H1>Motion Correction Report - Subject $SUBJECT$</H1><br>
</CENTER>

<CENTER>
<p><IMG BORDER=0 SRC="mc_rot.gif">
<p><IMG BORDER=0 SRC="mc_trans.gif">
<p><IMG BORDER=0 SRC="mc_disp.gif">
</CENTER>
<HR><FONT SIZE=-1>This report was produced automatically by fsl_preprocess.sh $DATE$<br> $PWD$</FONT><br>
ENDMCREPORT

BEGINNORMREPORT

<hr><CENTER>
<H1>Registration Report (FSL) - Subject $SUBJECT$</H1><br>
<H2>Target atlas - $TARGET$</H2><br>
</CENTER>
<hr><p>Registration of example_func (underlying image) to initial_highres (red lines)<br><br>
<a href="example_func2initial_highres.mat"><IMG BORDER=0 SRC="example_func2initial_highres.gif"></a><br>
<hr><p>Registration of initial_highres (underlying image) to highres (red lines)<br><br>
<a href="initial_highres2bhighres.mat"><IMG BORDER=0 SRC="initial_highres2bhighres.gif"></a><br>
<hr><p>Registration of example_func (underlying image) to highres (red lines)<br><br>
<a href="example_func2bhighres.mat"><IMG BORDER=0 SRC="example_func2bhighres.gif"></a><br>
<hr><p>Registration of highres (underlying image) to target (red lines)<br><br>
<a href="bhighres2target.mat"><IMG BORDER=0 SRC="bhighres2target.gif"></a><br>
<hr><p>Registration of example_func (underlying image) to target (red lines)<br><br>
<a href="example_func2target.mat"><IMG BORDER=0 SRC="example_func2target.gif"></a><br>
<HR><FONT SIZE=-1>This report was produced automatically by fsl_preprocess.sh $DATE$<br> $PWD$</FONT><br>

ENDNORMREPORT

BEGINSPMNORMREPORT

<hr><CENTER>
<H1>Registration Report (SPM) - Subject $SUBJECT$</H1><br>
<H2>Target atlas - $TARGET$<br>
EPI Target atlas - $EPITARGET$<br></H2>
</CENTER>
<hr><p>Registration of example_func (underlying image) to highres (red lines)<br><br>
<IMG BORDER=0 SRC="example_func2bhighres.gif"><br>
<hr><p>Registration of highres (underlying image) to target (red lines)<br><br>
<a href="bhighres2target.mat"><IMG BORDER=0 SRC="bhighres2target.gif"></a><br>
<hr><p>Registration of example_func (underlying image) to epi target (red lines)<br><br>
<IMG BORDER=0 SRC="example_func2target.gif"><br>
<HR><FONT SIZE=-1>This report was produced automatically by fsl_preprocess.sh $DATE$<br> $PWD$</FONT><br>

ENDSPMNORMREPORT


##### params file ######
BEGINPARAMS
#################################################################
# This is a parameter file that lists the specific anatomical
# and functional parameters hat are called upon in the
# preprocessing and fcMRI scripts.  It should be edited for
# each subject
################################################################

set subject             = SUBJID

# Number of frames to delete
@ skip                  = #NUMBER
set target              = "$_HVD_CODE_DIR/targets/N12Trio_avg152T1_brain.4dint"
set epitarget           = "$_HVD_SPM_DIR/templates/EPI.mnc"
set mprs                = (#SCAN_NUMBER)
set TR_vol              = #TR                             # functional TR

########## 2mm
set qc_folder           = 'qc'                         # quality control folder
set slab                = 0                            # 1 = slab registration
set BOLDbasename        = "$subject"_"bld*"_"*"FRM"*"_reorient.nii.gz
set fieldmap_correction = 0                             # 1 = fieldmap correction
set initial_highres     = (#INITIAL_HIGHRES_RUN)        # 2mm t1 weighted EPI
set highres             = (#HIGHRES_RUN)                           # 2mm whole brain t1 weighted EPI
set bold                = (#BOLD_RUN1 #BOLD_RUN2 ... #BOLD_RUNn)
set runid               = (RUN_ID1 RUN_ID2 ... RUN_IDn)
set bet_extract         = 1                             # 1 = brain extract (necessary when highres is T1 MPRAGE)

########## fcMRI specific parameters
if ($0 == `which fcMRI_preproc.csh`) then
set fcbold      = (#FCBOLD_RUN1 #FCBOLD_RUN2 ... #FCBOLD_RUNn)          # all functional connectivity runs
set runid       = (FCRUN_ID1 FCRUN_ID2 ... FCRUNn)
@ skip          = 0
set blur        = 0.735452                                              # Gaussian kernel for 4mm full width at 1/2 max
set oh          = 2                                                     # order of low pass filter
set ol          = 0                                                     # order of high pass filter
set bh          = 0.08                                                  # high end half frequency in hz
set bl          = 0                                                     # low end half frequency in hz
set ventreg     = $REFDIR/regions/avg152T1_ventricles                   # ventricle region
set wmreg       = $REFDIR/regions/avg152T1_WM                           # white matter region
set wbreg       = $REFDIR/regions/avg152T1_brain                        # whole brain region
set ppstr       = reorient_skip_faln_mc_atl                             # preprocessing string e.g. faln_dbnd_xr3d_222_t88
set mvstr       = reorient_skip_faln_mc                                 #
set G           = 1
endif

ENDPARAMS



##### help ######
BEGINHELP

PARAMETERS

These are set in the params file:

initial_highres_uthr     -  Set this variable to a numeric value to
                            apply an upper threshold when t1epi sequence
                            CSF distorts registration
                            E.g., set initial_highres_uthr = 800

mc_flags                 -  motion correction flags (see mcflirt)
epidewarp_flags          -  fieldmap based EPI dewarp flags (see epidewarp.sfl)
bet_flags                -  brain extraction flags (see bet)
**all the _flags variables take flags accepted by the respective FSL
  program. The additional arguments (flag -report for mcflirt should be assigned
  to the variable as follows: set mc_flags = "-report"; more than one flags can
  be assigned)


AUTHORS

Itamar Kahn.

REFERENCES AND ACKNOWLEDGMENTS

For bet:
S. Smith. Fast Robust Automated Brain Extraction in Human Brain
Mapping, 17(3), 143-155, 2002.

For mcflirt
M. Jenkinson, P. Bannister, M. Brady and S. Smith. Improved
Optimisation for the Robust and Accurate Linear Registration and
Motion Correction of Brain Images in NeuroImage, 17(2), 825-841, 2002.

For flirt:
M. Jenkinson and S.M. Smith. A Global Optimisation Method for Robust
Affine Registration of Brain Images in Medical Image Analysis, 5(2),
143-156, 2001.

For prelude:

M. Jenkinson. A Fast, Automated, N-Dimensional Phase Unwrapping
Algorithm Magnetic Resonance in Medicine, 49(1), 193-197, 2003.

For fugue:

M. Jenkinson. Improved Unwarping of EPI Volumes using Regularised B0
Maps International Conference on Human Brain Mapping - HBM2001.

Jezzard, Peter, and Balaban, Robert S. Correction for Geometric
Distortion in Echo Planar Images from B0 Field Variations. Mag Res
Med, 1995, 34:65-73.

For epidewarp.fsl we ask that the following be placed in the
acknowledgement section of you papers:

  "Some of the scripts involved in this work were developed by
   Doug Greve, Dave Tuch, Tom Liu, and Bryon Mueller,the FSL
   crew (www.fmrib.ox.ac.uk/fsl) and the Biomedical Informatics
   Research Network (www.nbirn.net)."
