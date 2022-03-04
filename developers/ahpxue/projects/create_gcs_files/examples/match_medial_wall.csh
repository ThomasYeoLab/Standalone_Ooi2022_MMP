#!/bin/csh -f
# match_medial_wall.csh -i <input_annot> -o <output_annot> -m <mesh> -?h"
# This script match the medial wall of your group parcellation to the medial wall defined by ?h.cortex.label. 

set mesh = "fsaverage"
set MATLAB = `which $CBIG_MATLAB_DIR/bin/matlab`

goto parse_args;
parse_args_return:
goto check_params;
check_params_return:

set scr_dir = `python -c "import os; print(os.path.realpath('$0'))"`
set scr_dir = `dirname $scr_dir`

set cortex_annot = "$SUBJECTS_DIR/${mesh}/label/${hemi}.label2annot.annot"
set cortex_label = "$SUBJECTS_DIR/${mesh}/label/${hemi}.cortex.label"

# Generate annot file from ?h.cortex.label
if( ! -e ${cortex_annot} ) then
    echo "Generating ${cortex_annot} from ${hemi}.cortex.label..."
    set cmd = "mris_label2annot --s fsaverage --h ${hemi} --ctab cortex.ctab --a label2annot --l ${cortex_label}"
    echo $cmd
    eval $cmd
else
    echo "${cortex_annot} already exists."
endif

# Adjust the annot file of your group level parcellation
echo "match_medial_wall('${input_annot}', '${output_annot}', '${cortex_annot}', '${mesh}')"
$MATLAB -nojvm -nodesktop -nosplash -r "addpath('${scr_dir}'); match_medial_wall('${input_annot}', '${output_annot}', '${cortex_annot}', '${mesh}'); exit;"

exit 0

#-------------------------------------------------#
parse_args:
#-------------------------------------------------#
set cmdline = "$argv";
while( $#argv != 0 )
    set flag = $argv[1]; shift;
    switch($flag)
        # input annot file
        case "-i":
        case "-input":
            if( $#argv < 1 ) goto arg1err
            set input_annot = $argv[1];shift;
            breaksw
        # output dir
        case "-o":
        case "-output":
            if( $#argv < 1 ) goto arg1err
            set output_annot = $argv[1]; shift;
            breaksw
        case "-m":
        case "-mesh":
            if( $#argv < 1 ) goto arg1err
            set mesh = $argv[1];shift;
            breaksw
        case "-lh":
            set hemi = "lh";
            breaksw
        case "-rh":
            set hemi = "rh";
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

if( ! -e $input_annot ) then
    echo "ERROR: Input annof file ${input_annot} does not exist."
endif

goto check_params_return;

#-------------------------------------------------#
arg1err:
#-------------------------------------------------#
echo "ERROR: flag $flag requires one argument"
exit 1
