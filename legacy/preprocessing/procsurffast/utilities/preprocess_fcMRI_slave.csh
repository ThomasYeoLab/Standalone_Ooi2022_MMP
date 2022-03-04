#! /bin/csh -f

## -----------
## --- checks!
## -----------
if($#argv < 6) then
    echo "usage: preprocess_fcMRI_slave.csh func_dir func_s anat_dir anat_s register_only best_reg $extract_frames_txt"
    echo " "
    echo "This is a utility function used by procsurffast.csh (psf)"
    echo " " 
    echo "func_dir           : directory where preprocessed functional data resides, i.e., -sdir argument to psf"
    echo "func_s             : subject's function ID, i.e., -s argument to psf"
    echo "anat_dir           : is directory where freesurfer preprocessed anatomical data resides, i.e., parent directory of "
    echo "                     -anat_dir argument to psf or -sdir argument to psf if -anat_dir not specified for psf"
    echo "anat_s             : subject's anatomical ID, i.e., {s}_FS if -anat_dir not specified for psf or basename of "
    echo "                     -anat_dir argument to psf"
    echo "register_only      : If 1, then only perform bold-T1 registration. If 0, then perform registration and fcMRI preprocessing"
    echo "best_reg           : If best_reg = 0, then use bbregister with flirt initialization for each bold run"
    echo "                     If best_reg = 1, then use bbregister with both flirt and spm initialization for each bold run,"
    echo "                     and the best registration (as measured by bbregister cost function) across all runs and both "
    echo "                     types of initializations are used"
    echo "                     IMPT NOTE: for best_reg = 1, it is necessary that spm is in your matlab paths. For example, this "
    echo "                     can be achieved by adding this line: addpath(getenv('_HVD_SPM_DIR')); in your startup.m file"
    echo "extract_frames_txt : If empty, then keep everything, else each line in text file indicates what frames to keep in corresponding bold run" 
    echo " "
    exit
endif


set func_dir = $1
set func_s = $2
set anat_dir = $3
set anat_s = $4
set register_only = $5
set best_reg = $6
set extract_frames_txt = $7
set SUBJECTS_DIR = $3
setenv SUBJECTS_DIR $3


## ----------------------
## --- grab function runs
## ----------------------
cd $func_dir/$func_s/scripts/
eval "`grep "fcbold" *.params`"

set zpdbold = ""
@ k = 1
while ($k <= ${#fcbold})
	set zpdbold = ($zpdbold `echo $fcbold[$k] | awk '{printf ("%03d",$1)}'`)
	@ k++
end
echo "bold runs = $zpdbold"
echo

## ----------------------
## --- perform bbregister
## ----------------------
if($best_reg) then

    ### --- first register each run using bbregister with both flirt and spm initialization
    foreach f ($zpdbold)
	cd $func_dir/$func_s/bold/$f
	set input = ${func_s}_bld${f}_rest_reorient_skip_faln_mc.nii.gz

	### --- register run using bbregister with flirt initialization
	mkdir -p init-fsl
	set reg = init-fsl/${func_s}_bld${f}_rest_reorient_skip_faln_mc.register.dat
	if(! -e $reg) then
	    set cmd = "bbregister --bold --s $anat_s --init-fsl --mov $input --reg ./$reg"
	    echo $cmd
	    eval $cmd
	    #tkregister2 --mov $input --reg ./$reg --surf
	else
	    echo "bbregister with flirt init completed for bold run: $f"
	endif

	### --- register run using bbregister with spm initialization
	mkdir -p init-spm
	set reg = init-spm/${func_s}_bld${f}_rest_reorient_skip_faln_mc.register.dat
	if(! -e $reg) then
	    set cmd = "bbregister --bold --s $anat_s --init-spm --mov $input --reg ./$reg"
	    echo $cmd
	    eval $cmd
	    #tkregister2 --mov $input --reg ./$reg --surf
	else
	    echo "bbregister with spm init completed for bold run: $f"
	endif
    end

    ### --- grab registration cost function values
    foreach init (fsl spm)
	set reg_cost_file = $func_dir/$func_s/bold/$init.cost
	if(-e $reg_cost_file) then
	    rm $reg_cost_file
	endif	
	foreach f ($zpdbold)
	    cat $func_dir/$func_s/bold/$f/init-$init/${func_s}_bld${f}_rest_reorient_skip_faln_mc.register.dat.mincost | awk '{print $1}' >> $reg_cost_file
	end
    end 
 
    ### --- compute best fsl cost
    set init_fsl = `cat $func_dir/$func_s/bold/fsl.cost`
    set min_fsl_cost = 100000
    set count = 1;
    while($count <= $#init_fsl)
	set comp = `echo "$init_fsl[$count] < $min_fsl_cost" | bc`
	if($comp == 1) then
	    set best_fsl_index = $count
            set min_fsl_cost   = $init_fsl[$count]
        endif
        @ count = $count + 1;
    end
    echo "Best fsl register is run $zpdbold[$best_fsl_index] with cost = $min_fsl_cost"
  
    ### --- compute best spm cost
    set init_spm = `cat $func_dir/$func_s/bold/spm.cost`
    set min_spm_cost = 100000
    set count = 1;
    while($count <= $#init_spm)
        set comp = `echo "$init_spm[$count] < $min_spm_cost" | bc`
        if($comp == 1) then
	    set best_spm_index = $count
            set min_spm_cost   = $init_spm[$count]
        endif
        @ count = $count + 1;
    end
    echo "Best spm register is run $zpdbold[$best_spm_index] with cost = $min_spm_cost"

    ### --- find out whether spm or fsl init is better
    set comp = `echo "$min_fsl_cost < $min_spm_cost" | bc`
    if($comp == 1) then
	set best_init = fsl
	set best_cost = $min_fsl_cost
	set best_run  = $best_fsl_index
    else
	set best_init = spm
	set best_cost = $min_spm_cost
	set best_run  = $best_spm_index
    endif   
    echo "Overall best init is $best_init with best run $zpdbold[$best_run] and cost $best_cost" 

    ### --- Use best registration!
    foreach f ($zpdbold)     
	set src = $func_dir/$func_s/bold/$zpdbold[$best_run]/init-$best_init/${func_s}_bld$zpdbold[$best_run]_rest_reorient_skip_faln_mc.register.dat	 
        set dst = $func_dir/$func_s/bold/$f/${func_s}_bld${f}_rest_reorient_skip_faln_mc.register.dat
	set cmd = "cp $src $dst"
        echo $cmd
        eval $cmd

        set src = $func_dir/$func_s/bold/$zpdbold[$best_run]/init-$best_init/${func_s}_bld$zpdbold[$best_run]_rest_reorient_skip_faln_mc.register.dat.sum
        set dst = $func_dir/$func_s/bold/$f/${func_s}_bld${f}_rest_reorient_skip_faln_mc.register.dat.sum
        set cmd = "cp $src $dst"
        echo $cmd
        eval $cmd

        set src = $func_dir/$func_s/bold/$zpdbold[$best_run]/init-$best_init/${func_s}_bld$zpdbold[$best_run]_rest_reorient_skip_faln_mc.register.dat.log
        set dst = $func_dir/$func_s/bold/$f/${func_s}_bld${f}_rest_reorient_skip_faln_mc.register.dat.log
        set cmd = "cp $src $dst"
        echo $cmd
        eval $cmd

        set src = $func_dir/$func_s/bold/$zpdbold[$best_run]/init-$best_init/${func_s}_bld$zpdbold[$best_run]_rest_reorient_skip_faln_mc.register.dat.mincost
        set dst = $func_dir/$func_s/bold/$f/${func_s}_bld${f}_rest_reorient_skip_faln_mc.register.dat.mincost
        set cmd = "cp $src $dst"
        echo $cmd
        eval $cmd
    end
else
    ### --- register each run using bbregister with flirt initialization
    foreach f ($zpdbold)
	cd $func_dir/$func_s/bold/$f
	set input = ${func_s}_bld${f}_rest_reorient_skip_faln_mc.nii.gz
	set reg = ${func_s}_bld${f}_rest_reorient_skip_faln_mc.register.dat

	if(! -e $reg) then
	    set cmd = "bbregister --bold --s $anat_s --init-fsl --mov $input --reg ./$reg"
	    echo $cmd
	    eval $cmd
	    #tkregister2 --mov $input --reg ./$reg --surf
	else
	    echo "bbregister completed for bold run: $f"
	endif
    end
endif
echo



if($extract_frames_txt == NONE) then
    # do not extract frames
else
    ## ------------------------------------
    ## --- extract frames
    ## ------------------------------------

    set count = 1;
    foreach f ($zpdbold) 
        cd $func_dir/$func_s/bold/$f
        set input  = ${func_s}_bld${f}_rest_reorient_skip_faln_mc.nii.gz
	set output = ${func_s}_bld${f}_rest_reorient_skip_faln_mc.nii.gz
	set frames = `head -n $count $extract_frames_txt | tail -n 1`

        matlab -nojvm -nodesktop -nosplash -r "GrabFrames $input $output '$frames'; exit"

	@ count = $count + 1
    end

    ## ----------------------------------------------
    ## --- Extract frames from motion correction files as well
    ## ----------------------------------------------

    set count = 1;
    cd $func_dir/$func_s/movement    
    foreach f ($zpdbold)

	set frames = `head -n $count $extract_frames_txt | tail -n 1`
	foreach type (dat rdat ddat)

	    set input = ${func_s}_bld${f}_rest_reorient_skip_faln_mc.$type
	    mv $input ${input}.orig
	    
	    foreach frame ($frames)
		head -n $frame ${input}.orig | tail -n 1 >> $input
	    end
	end

	@ count = $count + 1
    end

endif




if(! $register_only) then
    ## ------------------------------------
    ## --- Backproject segmentation results
    ## ------------------------------------
    foreach f ($zpdbold)
	cd $func_dir/$func_s/bold/$f
	set template = ${func_s}_bld${f}_rest_reorient_skip_faln_mc.nii.gz
	set reg = ${func_s}_bld${f}_rest_reorient_skip_faln_mc.register.dat

	if(! -e $func_s.brainmask.bin.nii.gz) then
	    set cmd = "mri_label2vol --seg $anat_dir/$anat_s/mri/aparc+aseg.mgz --temp $template --reg ./$reg --o ./$func_s.func.aseg.nii"
	    echo $cmd
	    eval $cmd
	    #tkmedit -f $template -seg $func_s.func.aseg.nii

	    set cmd = "mri_binarize --i $func_s.func.aseg.nii --wm --erode 1 --o $func_s.func.wm.nii.gz"
	    echo $cmd
	    eval $cmd
	    #tkmedit -f $template -ov $func_s.func.wm.nii.gz -fthresh .5

	    set cmd = "mri_binarize --i $func_s.func.aseg.nii --ventricles --o $func_s.func.ventricles.nii.gz"
	    echo $cmd
	    eval $cmd
	    #tkmedit -f $template -ov $func_s.func.ventricles.nii.gz -fthresh .5

	    set cmd = "mri_vol2vol --reg ./$reg --targ $anat_dir/$anat_s/mri/brainmask.mgz --mov $template --inv --o ./$func_s.brainmask.nii.gz"
	    echo $cmd
	    eval $cmd

	    set cmd = "mri_binarize --i $func_s.brainmask.nii.gz --o $func_s.brainmask.bin.nii.gz --min .0001"
	    echo $cmd
	    eval $cmd
	    # tkmedit -f $template -ov $func_s.brainmask.bin.nii.gz -fthresh .5
	else
	    echo "mask completed for bold run: $f"
	endif
    end
    echo

    ## ----------------------
    ## --- modify params file
    ## ----------------------
    cd $func_dir/$func_s/scripts
    if(! -e $func_s.params.fcMRI.orig) then
	cp $func_s.params $func_s.params.fcMRI.orig
    else
	rm $func_s.params
    endif


    sed -e "s@0.735452@100000000@g" $func_s.params.fcMRI.orig > tmp_params

    set replace_str = $func_dir/$func_s/bold/$zpdbold[1]/$func_s.func.ventricles.nii.gz
    set search_str  = $CODE_DIR/masks/avg152T1_ventricles_MNI
    sed -e "s@$search_str@$replace_str@g" tmp_params > tmp_params2

    set replace_str = $func_dir/$func_s/bold/$zpdbold[1]/$func_s.func.wm.nii.gz
    set search_str  = $CODE_DIR/masks/avg152T1_WM_MNI
    sed -e "s@$search_str@$replace_str@g" tmp_params2 > tmp_params3

    set replace_str = $func_dir/$func_s/bold/$zpdbold[1]/$func_s.brainmask.bin.nii.gz
    set search_str  = $CODE_DIR/masks/avg152T1_brain_MNI
    sed -e "s@$search_str@$replace_str@g" tmp_params3 > tmp_params4

    set replace_str = "ppstr=reorient_skip_faln_mc"
    set search_str  = "ppstr=reorient_skip_faln_mc_atl"
    sed -e "s@$search_str@$replace_str@g" tmp_params4 > tmp_params5

    mv tmp_params5 $func_s.params
    rm tmp_params tmp_params2 tmp_params3 tmp_params4
    echo

    ## --------------------
    ## --- preprocess fcMRI
    ## --------------------
    cd $func_dir
    set x = `ls $func_s/bold/*/*_rest_reorient_skip_faln_mc_g1000000000_bpss_resid.nii.gz`
    if($? == 1 || $#x != $#zpdbold) then
	set cmd = "fcMRI_preproc_nifti.csh $func_s"
	echo $cmd
	eval $cmd
    else
	echo "fcMRI preprocessing completed"
    endif
    echo

endif
