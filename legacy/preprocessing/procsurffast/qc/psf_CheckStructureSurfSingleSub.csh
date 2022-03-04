#! /bin/csh -f

# checks!
if($#argv < 3) then
    echo "usage: CheckStructureSurfSingleSub.csh s anat_s SUBJECTS_DIR"
    echo "IMPORTANT NOTE: There's a known bug in freeview such that the surface will not show up on the volume if this is run remotely from a mac"
    exit
endif

rm ~/.freeview
#source $CODE_DIR/bin/clear_fs_env.csh #unfortunately, this also clears the DYLD_LIBRARY_PATH
setenv FREESURFER_HOME $ROOT_DIR/apps/freesurfer5.1.0
source $FREESURFER_HOME/FreeSurferEnv.csh

set s = $1
set anat_s = $2
setenv SUBJECTS_DIR $3
set SUBJECTS_DIR = $3

set output_dir = $SUBJECTS_DIR/$s/qc/procsurffast/structure-surf
mkdir -p $output_dir

# print out for each bold run
set edgecolor = red;
set min_val = 0;
set max_val = 137;
set opacity = 1;
set width = 500;
set height = 500;
set zoom = 2;
set coronals = (-20 0 20 40 60)
set axials = (5 20 35 50 65)
set sagittals = (-30 -10 10 30)

set anat_volume = $SUBJECTS_DIR/$anat_s/mri/norm.mgz

# Draw with freeview and save coronal slices
if(! -e $output_dir/$s.coronal.png) then
    set combine_cmd = (convert)
    foreach coronal ($coronals) 
	    set cmd = "freeview --viewsize $width $height -viewport coronal -ras -200 $coronal -200 -ss $output_dir/coronal.$coronal.png -v ${anat_volume}:opacity=${opacity}:grayscale=${min_val},${max_val} -f $SUBJECTS_DIR/$anat_s/surf/lh.white:edgecolor=$edgecolor -f $SUBJECTS_DIR/$anat_s/surf/rh.white:edgecolor=$edgecolor --zoom $zoom"
	    echo $cmd
	    eval $cmd

	    convert -crop 280x300+110+70 $output_dir/coronal.$coronal.png $output_dir/coronal.$coronal.png
	    convert -flop $output_dir/coronal.$coronal.png $output_dir/coronal.$coronal.png # flip horizontal axis so as to be in neurological coordinates
	    set combine_cmd = ($combine_cmd $output_dir/coronal.$coronal.png)
    end
    set combine_cmd = ($combine_cmd +append $output_dir/$s.coronal.png)
    echo $combine_cmd
    eval $combine_cmd

endif

# Draw with freeview and save axial slices
if(! -e $output_dir/$s.axial.png) then
    set combine_cmd = (convert)
    foreach axial ($axials)
	set cmd = "freeview --viewsize $width $height -viewport axial -ras -200 -200 $axial -ss $output_dir/axial.$axial.png -v ${anat_volume}:opacity=${opacity}:grayscale=${min_val},${max_val} -f $SUBJECTS_DIR/$anat_s/surf/lh.white:edgecolor=$edgecolor -f $SUBJECTS_DIR/$anat_s/surf/rh.white:edgecolor=$edgecolor --zoom $zoom"
	echo $cmd
	eval $cmd

	convert -crop 280x350+110+45 $output_dir/axial.$axial.png $output_dir/axial.$axial.png
	convert -flop $output_dir/axial.$axial.png $output_dir/axial.$axial.png # flip horizontal axis so as to be in neurological coordinates
	set combine_cmd = ($combine_cmd $output_dir/axial.$axial.png)
    end
    set combine_cmd = ($combine_cmd +append $output_dir/$s.axial.png)
    echo $combine_cmd
    eval $combine_cmd
endif

# Draw with freeview and save sagittal slices
if(! -e $output_dir/$s.sagittal.png) then
    set combine_cmd = (convert)
    foreach sagittal ($sagittals)
	set cmd = "freeview --viewsize $width $height -viewport sagittal -ras $sagittal -200 -200 -ss $output_dir/sagittal.$sagittal.png -v ${anat_volume}:opacity=${opacity}:grayscale=${min_val},${max_val} -f $SUBJECTS_DIR/$anat_s/surf/lh.white:edgecolor=$edgecolor -f $SUBJECTS_DIR/$anat_s/surf/rh.white:edgecolor=$edgecolor --zoom $zoom"
	echo $cmd
	eval $cmd

	convert -crop 350x325+60+75 $output_dir/sagittal.$sagittal.png $output_dir/sagittal.$sagittal.png
	set combine_cmd = ($combine_cmd $output_dir/sagittal.$sagittal.png)
    end
    set combine_cmd = ($combine_cmd +append $output_dir/$s.sagittal.png)
    echo $combine_cmd
    eval $combine_cmd
endif

# create title
set title = $s.anatomy
convert -background black -fill white -size 350x50 -font Arial -pointsize 36 label:$title $output_dir/title.png

# Single summary
convert $output_dir/title.png $output_dir/$s.coronal.png $output_dir/$s.axial.png $output_dir/$s.sagittal.png -append $output_dir/$s.summary.png


if(-e $output_dir/$s.summary.png) then
    rm $output_dir/coronal.*.png
    rm $output_dir/sagittal.*.png
    rm $output_dir/axial.*.png
endif


#convert -font helvetica -fill white -pointsize 36 -draw "text 570,200 '$title'" $output_dir/$s.summary.png $output_dir/$s.summary.png
