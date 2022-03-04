#!/bin/csh -f
# make_gsp_links.csh -o <subject_dir> -l <subject_list>
# This script creates folder structure and make symbolic links for GSP subjects

# Change this after migrate
set indir="/mnt/eql/yeo1/data/GSP_release"
set outdir="/mnt/eql/yeo1/data/GSP_train_gcs/Subjects"
set sub_list="/mnt/eql/yeo1/data/GSP_release/subj.list"
setenv FREESURFER_HOME "/apps/arch/Linux_x86_64/freesurfer/6.0.0"

source $FREESURFER_HOME/SetUpFreeSurfer.csh

goto parse_args;
parse_args_return:
goto check_params;
check_params_return:

set subjects = `cat $sub_list`
set hemilist = (lh rh)

# Make symbolic links for GSP subjects
mkdir -p $outdir
foreach s ($subjects)
    echo "Subject: $s"
    mkdir -p $outdir/$s/label
    mkdir -p $outdir/$s/surf
    foreach hemi ($hemilist)
        if( ! -e "${outdir}/${s}/surf/${hemi}.smoothwm" ) then
            ln -s ${indir}/${s}_FS/surf/${hemi}.smoothwm ${outdir}/${s}/surf/${hemi}.smoothwm
        endif
        if( ! -e "${outdir}/${s}/surf/${hemi}.sphere.reg" ) then
            ln -s ${indir}/${s}_FS/surf/${hemi}.sphere.reg ${outdir}/${s}/surf/${hemi}.sphere.reg
        endif
        if( ! -e "${outdir}/${s}/label/${hemi}.cortex.label" ) then
            ln -s ${indir}/${s}_FS/label/${hemi}.cortex.label ${outdir}/${s}/label/${hemi}.cortex.label
        endif	
    end
end

# Make symbolic links for fsaverage
set fslist = (fsaverage5 fsaverage6 fsaverage)
foreach fs ($fslist)
    echo $fs
    mkdir -p $outdir/$fs/label
    foreach hemi ($hemilist)
        if( ! -e "${outdir}/${fs}/label/${hemi}.cortex.label" ) then
            ln -s $FREESURFER_HOME/subjects/${fs}/label/${hemi}.cortex.label ${outdir}/${fs}/label/${hemi}.cortex.label
        endif	
    end
    if( ! -e "${outdir}/${fs}/surf" ) then
        ln -s $FREESURFER_HOME/subjects/${fs}/surf ${outdir}/${fs}/surf
    endif
end

exit 0

#-------------------------------------------------#
parse_args:
#-------------------------------------------------#
set cmdline = "$argv";
while( $#argv != 0 )
    set flag = $argv[1]; shift;
    switch($flag)
        # output dir
        case "-o":
        case "-out":
        case "-outdir":
            if( $#argv < 1 ) goto arg1err
            set outdir = $argv[1]; shift;
            breaksw
        # subject list
        case "-l":
        case "-list":
            if( $#argv < 1 ) goto arg1err
            set sub_list = $argv[1];shift;
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

if( ! -e $sub_list ) then
    echo "ERROR: SUBJECT LIST ${sub_list} does not exist."
endif

goto check_params_return;

#-------------------------------------------------#
arg1err:
#-------------------------------------------------#
echo "ERROR: flag $flag requires one argument"
exit 1
