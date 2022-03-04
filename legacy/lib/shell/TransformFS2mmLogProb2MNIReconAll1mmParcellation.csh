#! /bin/csh -f

# checks!
if($#argv < 3) then
    echo "usage: TransformFS2mmLogProb2MNIReconAll1mmParcellation.csh input_logprob_file output_parcel_file mask"
    echo " "
    echo " mask = NONE implies no use of a mask"
    exit
endif

set curr_pwd = `pwd`

set input_file = $1
set output_file = $2
set mask_file = $3

# convert input_file to full path
set B = `basename $input_file`
set D = `dirname $input_file`
if(! -d $D) then
    echo "directory $D does not exist!"
    exit 1
else
    cd $D
    set input_file = `pwd`/$B
    echo $input_file
    cd $curr_pwd
endif


# convert output_file to full path
set B = `basename $output_file`
set D = `dirname $output_file`
if(! -d $D) then
    echo "directory $D does not exist!"
    exit 1
else
    cd $D
    set output_file = `pwd`/$B
    echo $output_file
    cd $curr_pwd
endif

# convert mask_file file to full path
if($mask_file != NONE) then
    set B = `basename $mask_file`
    set D = `dirname $mask_file`
    if(! -d $D) then
	echo "directory $D does not exist!"
	exit 1
    else
	cd $D
	set mask_file = `pwd`/$B
	echo $mask_file
	cd $curr_pwd
    endif
endif

# First Transform to MNIReconAll1mm Space
TransformMNIReconAll1mm2FS2mm.csh $input_file $output_file trilin 0

# Next find best parcellation
set cmd = "matlab -nojvm -nodesktop -nosplash -r 'ThresholdLogProb $output_file $output_file $mask_file'"
echo $cmd
eval $cmd
