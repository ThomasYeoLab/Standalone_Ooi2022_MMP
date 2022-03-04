#! /bin/csh -f
# Generate fake directories in the new directory <NEW_DIR> by creating links to the preprocessed data (standard pipeline) <OLD_DIR>
# Example: generate_fake_directories.csh <OLD_DIR> <NEW_DIR> <FS_DIR> <SUBJECT_ID>
# Example: generate_fake_directories.csh /Data/Experiments/ALFIE/Preprocess/ALFIE_RW_Resting_fcMRI /Data/Experiments/ALFIE/Preprocess/ALFIE_RW_Resting_fcMRI_compcor /Data/Experiments/ALFIE/Preprocess/ALFIE_FS ALFIE01
# Created by Thomas Yeo

# Path to original preprocessed data (with motion scrubbing)
set odir = $1
# Path to the new "fake" directory, where the no-global-regression preprocessed data will be written to
set ndir = $2 
# Path to subject's Freesurfer processed data
set FSdir = $3
# Subject ID
set subjects = $4

if ( ! -e ${ndir} ) then
    mkdir -p ${ndir}
endif



foreach s ($subjects)

    # fake recon-all
    cd $ndir
    ln -s $FSdir/${s}_FS

    # fake scripts/movement directories
    mkdir -p $ndir/$s
    cd $ndir/$s
    ln -s $odir/$s/scripts
    ln -s $odir/$s/movement
    ln -s $odir/$s/qc

    ### --- grab bold run
    set proc_script = $ndir/$s/scripts/$s.params
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

    foreach bold ($zpdbold)
	mkdir -p $ndir/$s/bold/$bold/
	cd $ndir/$s/bold/$bold/ 

	# generate fMRI volume
	ln -s $odir/$s/bold/$bold/${s}_bld${bold}_rest_reorient_skip_faln_mc.nii.gz
    
	# generate fake registration
	ln -s $odir/$s/bold/$bold/${s}_bld${bold}_rest_reorient_skip_faln_mc.register.dat
    end    

end
