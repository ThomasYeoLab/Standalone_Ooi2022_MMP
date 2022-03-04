#! /bin/csh -f

## -----------
## --- checks!
## -----------
if($#argv < 8) then
    echo "usage: CreateSurfFCMRIscript.csh $roi_hemi $sdir $subject $roi $script_name $surfsmooth $fsprojresolution $fsresolution"
    exit
endif

set roi_hemi = $1
set sdir = $2
set subject = $3
set roi = $4
set script_name = $5
set surfsmooth = $6
set fsprojresolution = $7
set fsresolution = $8

set root_dir = `dirname $0`
set bold_dir = $sdir/$subject/surf/
set script_dir = `dirname $script_name`

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

## --- Create bold runs text files
echo "Create bold runs text files"
foreach target_hemi (lh rh)
    set seed_txt = $script_dir/$target_hemi.bold.txt
    set bold_runs = ()
    foreach bold ($zpdbold)
	set bold_runs = ($bold_runs $bold_dir/$target_hemi.${subject}_bld${bold}_rest_reorient_skip_faln_mc_g1000000000_bpss_resid_${fsprojresolution}_sm${surfsmooth}_$fsresolution.nii.gz)
    end
    echo $bold_runs > $seed_txt
end

## --- Create Script 
echo "Create Script"
set output_base = $sdir/$subject/surf_fcMRI/
echo "#! /bin/csh -f" > $script_name
echo " " >> $script_name
echo "mkdir -p $output_base" >> $script_name
echo " " >> $script_name

#echo 'if ($?LD_LIBRARY_PATH) then' >> $script_name
#echo '   setenv LD_LIBRARY_PATH "$_HVD_MATLAB_DIR/bin/glnxa64":"$_HVD_MATLAB_DIR/sys/os/glnxa64/":"$LD_LIBRARY_PATH" ' >> $script_name
#echo 'else' >> $script_name
#echo '   setenv LD_LIBRARY_PATH "$_HVD_MATLAB_DIR/bin/glnxa64":"$_HVD_MATLAB_DIR/sys/os/glnxa64/"' >> $script_name
#echo 'endif' >> $script_name
#
#
#set varargin_text1 = $script_dir/$roi_hemi.bold.txt
#set ROIs1 = `cat $roi`
#foreach ROI ($ROIs1)
#echo " " >> $script_name
#set ROI = `python -c "import os; print os.path.realpath('$ROI')"`	 
#foreach target_hemi (lh rh)   
#    set output_file = $output_base/$target_hemi.`basename $ROI`.fcMRI.nii.gz    
#    set varargin_text2 = $script_dir/$target_hemi.bold.txt
#    set ROIs2  = $_HVD_CODE_DIR/ComputeROIs2ROIsCorrelationWithRegression/Yeo2011_surface_seeds/$target_hemi.{$fsresolution}_whole_surface.mgh
#
#    echo "ComputeROIs2ROIsCorrelationWithRegression $output_file $varargin_text1 $varargin_text2 $ROI $ROIs2 NONE NONE 1" >> $script_name    
#end
#end

set varargin_text1 = $script_dir/$roi_hemi.bold.txt
set ROIs1 = `cat $roi`
foreach ROI ($ROIs1)
echo " " >> $script_name
foreach target_hemi (lh rh)
    set output_file = $output_base/$target_hemi.`basename $ROI`.fcMRI.nii.gz
    set varargin_text2 = $script_dir/$target_hemi.bold.txt

    echo "ComputeROIs2WholeBrainCorrelationWithRegression $output_file $varargin_text1 $varargin_text2 $ROI NONE NONE NONE" >> $script_name
end
end



chmod +x $script_name
