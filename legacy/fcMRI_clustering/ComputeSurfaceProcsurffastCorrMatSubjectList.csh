#! /bin/csh -f

## -----------
## --- checks!
## -----------
if($#argv < 3) then
    echo "ComputeSurfaceProcsurffastCorrMatSubjectList.csh <SUBJECTS_DIR> <SUBJECT_LIST> <OUTPUT_DIR> <lh_roi_txt or NUM_NETWORKS> <rh_roi_txt>"
    echo "example: ComputeSurfaceProcsurffastCorrMatSubjectList.csh /cluster/nexus/13/users/ythomas/data/GSP/  subject_list /cluster/nexus/13/users/ythomas/data/GSP/scripts/surf_fcMRI/ 7"
    echo "example: ComputeSurfaceProcsurffastCorrMatSubjectList.csh /cluster/nexus/13/users/ythomas/data/GSP/  subject_list /cluster/nexus/13/users/ythomas/data/GSP/scripts/surf_fcMRI/ lh_roi_txt rh_roi_txt"
    echo " "
    echo "Compute within and across hemisphere correlation matrix"
    echo "Will compute <output_dir>/corr.lh2lh.mat, <output_dir>/corr.lh2rh.mat, <output_dir>/corr.rh2lh.mat, <output_dir>/corr.rh2rh.mat "
    exit
endif

set sdir = $1
set subjects = `cat $2`
set output_dir = $3

if($#argv > 4) then
    set lh_roi_txt = $4
    set rh_roi_txt = $5 
else
    if($#argv == 4) then
    	set num_networks = $4
    else
	set num_networks = 17
    endif

    set lh_roi_txt = $output_dir/lh_roi_txt
    set rh_roi_txt = $output_dir/rh_roi_txt
    set roi_dir =  $CODE_DIR/fcMRI_clustering/1000subjects_reference
    cat $roi_dir/lh.Yeo2011_${num_networks}Networks_N1000.split_components.txt | awk -v input_dir="$roi_dir/fsaverage5/split_labels$num_networks/" '{print input_dir$1}' > $lh_roi_txt
    cat $roi_dir/rh.Yeo2011_${num_networks}Networks_N1000.split_components.txt | awk -v input_dir="$roi_dir/fsaverage5/split_labels$num_networks/" '{print input_dir$1}' > $rh_roi_txt
endif

echo "Running ComputeSurfaceProcsurffastCorrMat subjects listed in $2, subjects assumed to be in $sdir and outputing results in $output_dir"
echo "using ROIs: $lh_roi_txt and $rh_roi_txt"
echo 

mkdir -p $output_dir

# Creating input bold files
set lh_input_file = $output_dir/lh.$$.bold.input
rm $lh_input_file

set rh_input_file = $output_dir/rh.$$.bold.input 
rm $rh_input_file

foreach s ($subjects)
	cd $sdir/$s/scripts
	eval "`grep "fcbold" *.params`"
	
	set zpdbold = ""
	@ k = 1
	while ($k <= ${#fcbold})
	    set zpdbold = ($zpdbold `echo $fcbold[$k] | awk '{printf ("%03d",$1)}'`)
	    @ k++
	end

	@ k = 1
	set str = ""
	while ($k <= ${#fcbold})
		set str = ($str "$sdir/$s/surf/lh.${s}_bld$zpdbold[$k]_rest_reorient_skip_faln_mc_g1000000000_bpss_resid_fsaverage6_sm6_fsaverage5.nii.gz") 
		@ k++
	end
	echo $str >> $lh_input_file
	    
	@ k = 1
	set str = ""
	while ($k <= ${#fcbold})
		set str = ($str "$sdir/$s/surf/rh.${s}_bld$zpdbold[$k]_rest_reorient_skip_faln_mc_g1000000000_bpss_resid_fsaverage6_sm6_fsaverage5.nii.gz")
		@ k++
	end
	echo $str >> $rh_input_file
end

# Compute within left hemisphere correlation
set output_file = $output_dir/corr.lh2lh.mat
if(! -e $output_file) then
	set cmd = "ComputeROIs2ROIsCorrelationWithRegression $output_file $lh_input_file $lh_input_file $lh_roi_txt $lh_roi_txt NONE NONE 1"
	eval $cmd
else
	echo "Completed corr_mat $output_file"
endif

# Compute within right hemisphere correlation
set output_file = $output_dir/corr.rh2rh.mat
if(! -e $output_file) then
        set cmd = "ComputeROIs2ROIsCorrelationWithRegression $output_file $rh_input_file $rh_input_file $rh_roi_txt $rh_roi_txt NONE NONE 1"
        eval $cmd
else
        echo "Completed corr_mat $output_file"
endif

# Compute left to right correlation
set output_file = $output_dir/corr.lh2rh.mat
if(! -e $output_file) then
        set cmd = "ComputeROIs2ROIsCorrelationWithRegression $output_file $lh_input_file $rh_input_file $lh_roi_txt $rh_roi_txt NONE NONE 1"
        eval $cmd
else
        echo "Completed corr_mat $output_file"
endif

# Compute right to left correlation
set output_file = $output_dir/corr.rh2lh.mat
if(! -e $output_file) then
        set cmd = "ComputeROIs2ROIsCorrelationWithRegression $output_file $rh_input_file $lh_input_file $rh_roi_txt $lh_roi_txt NONE NONE 1"
        eval $cmd
else
        echo "Completed corr_mat $output_file"
endif



