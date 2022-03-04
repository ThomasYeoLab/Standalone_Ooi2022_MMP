#!/bin/tcsh 

set VERSION = '$Id: unpack_fsl_nii.sh, v 1.0 2015/05/05 13:15 ythomas Exp $'
#Modified from unpack_fsl.sh,v 1.0 2008/02/15 13:38:22 mtt24 Exp $'

if ($#argv == 0) then
  echo ""
  echo "USAGE (with DICOM input): unpack_fsl_nii.sh -subid 060708_4TT00030 -rawdir /data/060708_4TT00030/RAW/ -cfgdir /ncf/mtt24/070609_4TT00262/scripts"
  echo "USAGE (with NIfTI input): unpack_fsl_nii.sh -subid 060708_4TT00030 -rawnii /scripts/060708_4TT00030_rawnii.txt -cfgdir /ncf/mtt24/070609_4TT00262/scripts"
  echo "USAGE (with NIfTI input and reorientation is needed): unpack_fsl_nii.sh -subid 060708_4TT00030 -rawnii /scripts/060708_4TT00030_rawnii.txt -cfgdir /ncf/mtt24/070609_4TT00262/scripts -niireorient"
  echo "To decide you need to perform reorientation, load data in freeview. If your nifti volumes are alerady in this orientation (below), then no need to reorient."
  echo "        Scroll down coronal, 2nd voxel coordinate decreases"
  echo "        Scroll down sagittal, 1st voxel coordinate increases"
  echo "        Scroll down axial, 3rd voxel coordinate decreases" 
  echo "Version: " $VERSION
  exit 0;
endif

echo "$VERSION"

set program = 'unpack_fsl_nii.sh'
set cmdline = ($argv);
set dirscript = 0;
while( $#argv != 0 )

set flag = $argv[1]; shift;
   switch($flag)
   case "-subid":
      if ( $#argv == 0) then 
      echo  "ERROR: flag $flag requires one argument"
      exit -1;
      endif
      set cmdline = ($argv);
      set subid = $argv[1]; shift
      breaksw
   case "-rawdir":
      if ( $#argv == 0) then 
      echo  "ERROR: flag $flag requires one argument"
      exit -1;
      endif
      set cmdline = ($argv);
      set rawdir = $argv[1]; shift
      if (! -e $rawdir) then
      echo "ERROR: cannot find raw data directory " $rawdir
      exit -1;
      endif
      breaksw
   case "-rawnii":
      if ( $#argv == 0 ) then
      echo  "ERROR: flag $flag requires one argument"
      exit -1;
      endif
      set cmdline = ($argv);
      set rawnii = $argv[1]; shift
      if (! -e $rawnii) then
      echo "ERROR: cannot find raw data directory " $rawnii
      exit -1;
      endif
      breaksw
   case "-cfgdir":
      if ( $#argv == 0) then 
      echo  "ERROR: flag $flag requires one argument"
      exit -1;
      endif
      set cmdline = ($argv);
      set dirscript = $argv[1]; shift
      
      if (! -e $dirscript) then
      echo "ERROR: cannot find scripts directory" $dirscript
      exit -1;
      endif
      breaksw
   case "-niireorient":
      set cmdline = ($argv);
      set niireorient = 1;
      breaksw
   default:
      echo ERROR: Flag $flag unrecognized. 
      echo $cmdline
      exit -1
   endsw

end

if ( $?rawnii == 1 & $?rawdir == 1 ) then
   echo "ERROR: found two types of raw data: DICOM and NIfTI"
   echo "You can only specify 1 type of raw data"
   exit -1
endif

if ( $?rawnii == 0 & $?rawdir == 0 ) then
   echo "ERROR: cannot find raw data"
   exit -1
endif


if ($dirscript == 0) then 
set dirscript = `pwd`;
endif


echo "INFO: Checking for .cfg file"
if (! -e $dirscript/$subid"_unpack_fsl.cfg") then
    echo "ERROR: cannot find .cfg file in $dirscript"
    echo "specify directory where $subid_unpack_fsl.cfg file resides using -cfgdir option"
exit -1

else 
set cfgfile = $dirscript/$subid"_unpack_fsl.cfg"
echo "FOUND : $cfgfile" 
endif

if ( $?rawdir == 1 ) then
	# Choose DICOM images as input
	echo "INFO: Running unpacksdcmdir..."
	unpacksdcmdir -src $rawdir -targ ../ -cfg $cfgfile -unpackerr
	echo "INFO: done."
	mv ../dicomdir.sumfile ../unpack.log .
else
	# Chosse NIfTI files as input
	set nrun = `cat ${cfgfile} | awk '{print $1}'`
	set nnii = `cat ${rawnii}`
	# Check if the number of runs specified matches raw nii files
	if ( $#nrun != $#nnii ) then
	echo "ERROR: Number of runs does not match raw data"
	exit -1
	endif
	echo "Raw images have been converted to NIfTI. Taking these NIfTI files as raw data."
	@ a = 1
	foreach rawniifiles ( $nnii )
		set foldernow = ../`cat ${cfgfile} | head -n $a | tail -n 1 | awk '{print $2}'`/`printf %03d $nrun[$a]`
		echo "Creating new directory: ${foldernow}"
		mkdir -p ${foldernow}
		set fileformat = `basename ${rawniifiles} | cut -d'.' -f2-`
		echo $fileformat
		if ( $fileformat == "nii.gz" ) then
			# Unpack .nii.gz files
			cp ${rawniifiles} ${foldernow}/`cat ${cfgfile} | head -n $a | tail -n 1 | awk '{print $4}'`.gz
			fslchfiletype NIFTI ${foldernow}/`cat ${cfgfile} | head -n $a | tail -n 1 | awk '{print $4}'`.gz
		else
			echo "ERROR: Input NIfTI volumes need to be in .nii.gz format!"
			exit -1
#			cp ${rawniifiles} ${foldernow}/`cat ${cfgfile} | head -n $a | tail -n 1 | awk '{print $4}'`
		endif
		
	@ a+=1
	end
endif


cd ../
foreach folder ('anat' 'bold' 'fieldmap')
 echo $folder
 if(-e $folder) then
 cd $folder
 foreach item (`ls -d 0*`)
    cd $item
    foreach niifile (*.nii)

	if ( $?niireorient == 0 & $?rawnii == 1 ) then
		echo "We assume your raw NIfTI volumes have the correct orientation, so that we do NOT perform any reorientation"
		set reorienttmp = "`basename $niifile .nii`_reorient.nii"
		cp $niifile ${reorienttmp}
		fslchfiletype NIFTI_GZ ${reorienttmp}
		rm ${reorienttmp}
	else

	# THIS IS THE WAY OF REORIENTATION IN THE ORIGINAL PIPELINE
	#        if (`echo $niifile | awk 'BEGIN {k=0;}; $1~/mpr/{k=1}; END {print k;};'`) then
	#            echo reorient MPRAGE "$item"/"$niifile"
	#            fslswapdim $niifile z -x -y `basename $niifile .nii`_reorient.nii
	#         else
	#            echo reorient bold/anat/fieldmap "$item"/"$niifile"
	#            fslswapdim $niifile x -y z `basename $niifile .nii`_reorient.nii
	#         endif
	#    echo "fslorient -forceradiological `basename $niifile .nii`_reorient.nii"
	#    fslorient -forceradiological `basename $niifile .nii`_reorient.nii
	##########################################################################################

	# NEW ORIENTATION METHOD
	     echo reorient bold/anat/fieldmap "$item"/"$niifile"
             set reorienttmp = "`basename $niifile .nii`_reorient.nii.gz"
             set cmd = "fslreorient2std $niifile ${reorienttmp}"
	     echo $cmd
	     eval $cmd
             # Check if ${reorienttmp} is "NEUROLOGICAL". If yes, we will flip left/right and then force RADIOLOGICAL to match the orientation of data preprocessed from DICOM input (original pipeline).
             if ( `fslorient -getorient ${reorienttmp}` == NEUROLOGICAL ) then
                echo "Converting $reorienttmp orientation, from neurological to radiological"
                fslswapdim ${reorienttmp} -x y z radiological_tmp.nii.gz
                fslorient -forceradiological radiological_tmp.nii.gz
		rm ${reorienttmp}
                mv radiological_tmp.nii.gz ${reorienttmp}
             endif
		

	endif

    end
    cd ../
 end
 cd ../
 else
     echo "$folder does not exist"
 endif
end

