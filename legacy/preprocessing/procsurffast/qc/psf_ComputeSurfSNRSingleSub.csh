#! /bin/csh -f

# checks!
if($#argv < 3) then
    echo "usage: psf_ComputeSurfSNRSingleSub.csh s anat_s SUBJECTS_DIR"
    exit
endif

set s = $1
set anat_s = $2
setenv SUBJECTS_DIR $3
set SUBJECTS_DIR = $3

set output_dir = $SUBJECTS_DIR/$s/qc/procsurffast/surf-SNR/
mkdir -p $output_dir

# grab bold runs
cd $SUBJECTS_DIR/$s/scripts/
eval "`grep "fcbold" *.params`"

set zpdbold = ""
@ k = 1
while ($k <= ${#fcbold})
	set zpdbold = ($zpdbold `echo $fcbold[$k] | awk '{printf ("%03d",$1)}'`)
	@ k++
end

# first compute SNR
set outputs = `ls $output_dir/?h.$s.avg.snr.nii.gz`
if($#outputs < 2) then    
    foreach f ($zpdbold)    
	# first compute SNR for each bold run
	set raw = $SUBJECTS_DIR/$s/bold/$f/${s}_bld${f}_rest_reorient_skip_faln_mc.nii.gz
	set raw_snr = $output_dir/$s.$f.snr.nii.gz    
	set raw_mean = $output_dir/$s.$f.mean.nii.gz
	set raw_std = $output_dir/$s.$f.std.nii.gz

	if(! -e $raw_snr) then
	    set cmd = "fslmaths $raw -Tmean $raw_mean"
	    echo $cmd
	    eval $cmd

	    set cmd = "fslmaths $raw -Tstd $raw_std"
	    echo $cmd
	    eval $cmd

	    set cmd = "fslmaths $raw_mean -div $raw_std $raw_snr"
	    echo $cmd
	    eval $cmd
	endif

	if(-e $raw_snr) then
	    rm $raw_mean
	    rm $raw_std
	endif
    end  

    # Now project SNR to the surface
    foreach f ($zpdbold)
	foreach hemi (lh rh)
	    set reg = $SUBJECTS_DIR/$s/bold/$f/${s}_bld${f}_rest_reorient_skip_faln_mc.register.dat
	    set vol_snr = $output_dir/$s.$f.snr.nii.gz
	    set surf_snr = $output_dir/$hemi.$s.$f.snr.nii.gz

	    if(! -e $surf_snr) then
		set cmd = "mri_vol2surf --mov $vol_snr --reg $reg --hemi $hemi --projfrac 0.5 --trgsubject fsaverage5 --o $surf_snr --reshape --interp trilinear"
		echo $cmd
		eval $cmd
	    endif
	end
    end

    # compute average SNR
    foreach hemi (lh rh) 
        if(! -e $output_dir/$hemi.$s.avg.snr.nii.gz) then
	    if($#zpdbold == 1) then 
	        cp $output_dir/$hemi.$s.$f.snr.nii.gz $output_dir/$hemi.$s.avg.snr.nii.gz 
	    else
	        fslmerge -t $output_dir/$hemi.$s.avg.snr.nii.gz $output_dir/$hemi.$s.*.snr.nii.gz
	        fslmaths $output_dir/$hemi.$s.avg.snr.nii.gz -Tmean $output_dir/$hemi.$s.avg.snr.nii.gz
	    endif
        endif
    end
else
    echo "Surface SNR for $s completed"
endif




