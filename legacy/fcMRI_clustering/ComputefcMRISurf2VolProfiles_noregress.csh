#! /bin/csh -f

# checks!
if($#argv < 6) then
    echo "usage: ComputefcMRISurf2VolProfiles_noregress.csh SUBJECTS_DIR SUBJECT OUTPUT_DIR VOL_MASK OUTPUT_PREFIX INPUT_POSTFIX"
    echo "assumes subject has been processed by procsurffast.csh and procsurffast outputs in <SUBJECTS_DIR>/<SUBJECT>"
    exit
endif

set sdir = $1
set s = $2
set output_dir = $3
set volume_mask_orig = $4
set volume_mask = \'$volume_mask_orig\'
set output_prefix = $5
set input_postfix = $6


set roi = fsaverage3
set target = fsaverage5
set threshold = 0.1
set output_file = \'$output_dir/lh.$s.$output_prefix.roi$roi.thres$threshold.surf2vol_profile.mat\'
set roi_orig = $roi;
set roi = \'$roi\'
set target_orig = $target;
set target = \'$target\'
set threshold_orig = $threshold;
set threshold = \'$threshold\'

echo "Compute correlation profile for $sdir/${s}, writing outputs in $output_dir with prefix $output_prefix"

# Grab bold parameters
cd $sdir/$s/scripts/
eval "`grep "fcbold" *.params`"

set zpdbold = ""
@ k = 1
while ($k <= ${#fcbold})
    set zpdbold = ($zpdbold `echo $fcbold[$k] | awk '{printf ("%03d",$1)}'`)
    @ k++
end 

mkdir -p $output_dir

# Create input files
set lh_input_file = $output_dir/lh.$s.$output_prefix.roi$roi_orig.thres$threshold_orig.surf2vol_profile.input
rm $lh_input_file
@ k = 1
while ($k <= ${#fcbold})
    echo "$sdir/$s/surf/lh.${s}_bld$zpdbold[$k]_rest_reorient_skip_faln_mc_g1000000000_bpss_resid_fsaverage6_sm6_fsaverage5.nii.gz" >> $lh_input_file
    @ k++
end
set lh_input_file = \'$lh_input_file\'

set vol_input_file = $output_dir/$s.$output_prefix.roi$roi_orig.thres$threshold_orig.surf2vol_profile.input
rm $vol_input_file
@ k = 1
while ($k <= ${#fcbold})
    echo "$sdir/$s/vol/${s}_bld$zpdbold[$k]_rest_reorient_skip_faln_mc_g1000000000_bpss_resid_${input_postfix} " >> $vol_input_file
    @ k++
end
set vol_input_file = \'$vol_input_file\'

# Clustering
cd $output_dir
set MATLAB=`which $_HVD_MATLAB_DIR/bin/matlab`
if($status) then
    echo "ERROR: could not find matlab"
    exit 1;
endif

################## Start Matlab
$MATLAB -nodesktop -nosplash << EOF

bty_pwd = pwd;
CODE_DIR = getenv('_HVD_CODE_DIR');
cd(fullfile(CODE_DIR, 'bin'));
ythomas_generic_startup;
cd(bty_pwd);

ComputeCorrelationProfileSurf2Vol_noregress(${roi}, ${target}, ${output_file}, ${threshold}, ${volume_mask}, ${vol_input_file}, ${lh_input_file});
if exist('matlab_done.touch','file')
    !rm matlab_done.touch
end
!touch matlab_done.touch
EOF

################## End Matlab
if (! -e matlab_done.touch) then
    echo Matlab fails to compute Correlation Profiles. Aborting.
    exit -1;
else
    rm matlab_done.touch
endif

