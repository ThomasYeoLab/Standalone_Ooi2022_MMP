#! /bin/csh -f
# This script will re-run the standard preprocessing pipeline from fcMRI preprocessing (i.e. spatial blurring -> bandpass filtering -> regression of movement parameters, white matter, ventricle (+derivatives)), and then surface projection, assuming you have processed your data using the standard pipeline (at least until motion-corrected images have been produced)
# First, this script will create fake directories where "scripts", "qc", "movement", "bold/###/*mc.nii.gz", "bold/###/*mc.register.dat" are taken from the standard preprocessing
# Then it will start fcMRI preprocessing and surface projection
# Created by Jesisca Tandi and Thomas Yeo

if ( $#argv != 4 ) then
    echo "preprocess_NoGlobalRegress_surf.csh SUBJECTID ORIGINALFUNC_DIR FS_DIR NEWFUNC_DIR"
    echo "Example: preprocess_NoGlobalRegress_surf.csh ALFIE01 /Data/Experiments/ALFIE/Preprocess/ALFIE_RW_Resting_fcMRI /Data/Experiments/ALFIE/Preprocess/ALFIE_FS /Data/Experiments/ALFIE/Preprocess/ALFIE_RW_Resting_fcMRI_noglobreg"
    exit 1
endif

set subject = $1
set oldfuncdir = $2
set FSdir = $3
set newfuncdir = $4

# Generate fake directories (from original preprocessed data)
${CODE_DIR}/procsurffast/NoGlobalRegSurface/generate_fake_directories.csh ${oldfuncdir} ${newfuncdir} ${FSdir} ${subject}
# Run fc preprocessing with whole-brain regression and then project to surface
${CODE_DIR}/procsurffast/NoGlobalRegSurface/preprocess_NoGlobalRegress_slave_surf.csh ${subject} ${newfuncdir}

