#!/bin/csh -f
# train_gcs.csh -d <annot_dir> -a <annot_name> -l <subject_list> -c <colortable_name>
# This script uses mri_surf2surf to create individual parcallation and use mris_ca_train to create gcs files.
# The colortable should be split into lh and rh. Colortable for each hemisphere should ONLY contain existing parcels.
# The colortable should be put under the same folder of this script. 
# The subject list is a text file of the subject names of the training set

goto parse_args;
parse_args_return:
goto check_params;
check_params_return:

set subjects = `cat $sub_list`
set hemilist = (lh rh)

# Project group level parcellation to individual surface space
foreach s ($subjects)
    echo "Projecting subject $s ..."
    foreach hemi ($hemilist)
        set cmd="mri_surf2surf --cortex --srcsubject fsaverage --trgsubject ${s}"
        set cmd="${cmd} --hemi ${hemi} --sval-annot ${annot_dir}/${hemi}.${group_annot_name}.annot"
        set cmd="${cmd} --tval ${hemi}.${annot_name}.annot"
        echo $cmd
        eval $cmd
    end
end

# Training
echo "Start training ..."
foreach hemi ($hemilist)
    set colortable="${hemi}.${colortable_name}.txt"
    set cmd="mris_ca_train -t ${colortable} ${hemi} sphere.reg ${annot_name}"
    foreach s ($subjects)
        set cmd="${cmd} ${s}"
    end
    set cmd="${cmd} ${gcs_dir}/${hemi}.${gcs_name}.gcs"
    echo $cmd
    eval $cmd
    echo "gcs file saved to ${gcs_dir}/${hemi}.${gcs_name}.gcs"
end

exit 0

#-------------------------------------------------#
parse_args:
#-------------------------------------------------#
set cmdline = "$argv";
while( $#argv != 0 )
    set flag = $argv[1]; shift;
    switch($flag)
        case "-d":
        case "-ad":
        case "-annotdir":
            if( $#argv < 1 ) goto arg1err
            set annot_dir = $argv[1]; shift;
            breaksw
        case "-sd":
        case "-sdir":
            if( $#argv < 1 ) goto arg1err
            setenv SUBJECTS_DIR $argv[1]; shift;
            breaksw
        case "-a":
        case "-annot":
            if( $#argv < 1 ) goto arg1err
            set group_annot_name = $argv[1];shift;
            breaksw
        case "-name":
            if( $#argv < 1 ) goto arg1err
            set annot_name = $argv[1];shift;
            breaksw
        case "-o":
        case "-od":
        case "-odir":
            if( $#argv < 1 ) goto arg1err
            set gcs_dir = $argv[1];shift;
            breaksw
        case "-l":
        case "-list":
            if( $#argv < 1 ) goto arg1err
            set sub_list = $argv[1];shift;
            breaksw
        case "-g":
        case "-gcs":
            if( $#argv < 1 ) goto arg1err
            set gcs_name = $argv[1];shift;
            breaksw
        case "-c":
        case "-ctab":
        case "-colortable":
            if( $#argv < 1 ) goto arg1err
            set colortable_name = $argv[1];shift;
            breaksw
        case "-lh":
            set hemilist = lh
            breaksw
        case "-rh":
            set hemilist = rh
            breaksw
        default:
            echo "ERROR: Flag $flag unrecognized."
            echo $cmdline
            exit 1
            breaksw
    endsw
end

goto parse_args_return;

#-------------------------------------------------#
check_params:
#-------------------------------------------------#

if(! $?annot_name ) then
    set annot_name = $group_annot_name
endif

if(! $?gcs_dir ) then
    set gcs_dir = `pwd`
endif

if(! $?gcs_name ) then
    set gcs_name=${annot_name}
endif

goto check_params_return;

#-------------------------------------------------#
arg1err:
#-------------------------------------------------#
echo "ERROR: flag $flag requires one argument"
exit 1
