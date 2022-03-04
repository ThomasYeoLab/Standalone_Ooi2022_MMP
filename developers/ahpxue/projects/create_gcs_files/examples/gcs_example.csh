#!/bin/csh -f
# gcs_example.csh <output_dir>
# This is an example to generate gcs files for Schaefer2018, 400 parcels, 17 networks parcellation.
# Default output_dir is /mnt/eql/yeo1/data/GSP_train_gcs

# Change this after migrate
setenv FREESURFER_HOME "/apps/arch/Linux_x86_64/freesurfer/6.0.0"
set subj_list = "/mnt/eql/yeo1/data/GSP_release/subj.list"
set default_outdir = "/mnt/eql/yeo1/data/GSP_train_gcs"

set mesh = "fsaverage"
set par_name = "Schaefer2018_400Parcels_17Networks_order"
set par_dir = "$CBIG_CODE_DIR/stable_projects/brain_parcellation/Schaefer2018_LocalGlobal/Parcellations/FreeSurfer5.3/${mesh}/label"
set annot_name = "Schaefer2018_400Parcels_17Networks"

if( $#argv == 0 ) then
    set outdir = ${default_outdir}
else
    set outdir = $argv[1]
endif

setenv SUBJECTS_DIR "${outdir}/Subjects"
source $FREESURFER_HOME/SetUpFreeSurfer.csh

set scr_dir = `python -c "import os; print(os.path.realpath('$0'))"`
set scr_dir = `dirname $scr_dir`
cd $scr_dir

echo "FREESURFER_HOME: $FREESURFER_HOME"
echo "SUBJECTS_DIR: $SUBJECTS_DIR"

set hemilist = (lh rh)

##################################################################
# Create folder structure and make symbolic links for GSP subjects
##################################################################

echo "===>> Creating symbolic links for GSP subjects..."
set cmd = "csh make_gsp_links.csh -o $SUBJECTS_DIR -l ${subj_list}"
echo $cmd
eval $cmd

foreach hemi ($hemilist)
    echo "===>> Matching medial wall of group level parcellation..."
    set input_annot = "${par_dir}/${hemi}.${par_name}.annot"
    set output_annot = "${outdir}/group_annot/${mesh}/${hemi}.${par_name}_matched.annot"
    if( ! -e "${outdir}/group_annot/${mesh}" ) then
        mkdir -p ${outdir}/group_annot/${mesh}
    endif

    # Match the medial wall defined by ?h.cortex.label
    if( ! -e ${output_annot} ) then
        set cmd = "csh match_medial_wall.csh -i ${input_annot} -o ${output_annot} -m ${mesh} -${hemi}"
        echo $cmd
        eval $cmd
    else
        echo "Output annot ${output_annot} already file exists."
    endif
    ln -s $scr_dir/colortable/${hemi}.${annot_name}_Colortable.txt $scr_dir/${hemi}.${annot_name}_Colortable.txt 
end

##################################################
# Create annot files on the training set and train
##################################################

echo "===>> Start training procedure..."
if( ! -e "${outdir}/gcs" ) then
    mkdir -p ${outdir}/gcs
endif
set cmd="csh train_gcs.csh -d ${outdir}/group_annot/${mesh} -a ${par_name}_matched -o ${outdir}/gcs -g ${annot_name} -name ${annot_name} -c ${annot_name}_Colortable -l ${subj_list}"
echo $cmd
eval $cmd

foreach hemi ($hemilist)
    rm $scr_dir/${hemi}.${annot_name}_Colortable.txt 
end

echo "End of generating gcs files for ${annot_name}."
