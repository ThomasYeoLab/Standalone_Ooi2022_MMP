#!/bin/tcsh 

set VERSION = '$Id: unpack_fsl.sh,v 1.0 2008/02/15 13:38:22 mtt24 Exp $'

if ($#argv == 0) then
  echo ""
  echo "USAGE: unpack_fsl.sh -subid 060708_4TT00030 -rawdir /data/060708_4TT00030/RAW/ -cfgdir /ncf/mtt24/070609_4TT00262/scripts"
  echo ""
  echo "Version: " $VERSION
  exit 0;
endif

echo "$VERSION"

set program = 'unpack_fsl.sh'
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
   default:
      echo ERROR: Flag $flag unrecognized. 
      echo $cmdline
      exit -1
      breaksw
   endsw
end

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


echo "INFO: Running mri_convert..."
set scan_num = `cut -d' ' -f2 "$cfgfile"| awk '{printf "%03d", $1}'`
set out_fname = `cut -d' ' -f5 "$cfgfile"`
set out_dir = "../anat/$scan_num"
mkdir -p "$out_dir" || exit 1

echo "SCAN NUMBER=$scan_num"
echo "OUTPUT FILE NAME=$out_fname"

## --- find a single DICOM file
set one_file = ""
foreach file (`ls "$rawdir"`)
    dicom_test -f "$rawdir/$file"
    if ($? == 0) then
        set one_file = $file
        break
    endif
end

if ($one_file == "") then
	echo "FATAL: Could not find a single DICOM file in '$rawdir'"
endif

echo "SINGLE DICOM=$one_file"

set cmd = "mri_convert '$rawdir/$one_file' '$out_dir/$out_fname'"
echo "Running command: $cmd"
mri_convert "$rawdir/$one_file" "$out_dir/$out_fname" || exit 1
#unpacksdcmdir -src $rawdir -targ ../ -cfg $cfgfile -unpackerr
echo "INFO: done."
## --- these file are made by unpacksdcmdir, not mri_convert
#mv ../dicomdir.sumfile ../unpack.log .

cd ../
foreach folder ('anat' 'bold' 'fieldmap')
 echo $folder
 cd $folder
 foreach item (`ls -d 0*`)
    cd $item
    foreach niifile (*.nii)
        if (`echo $niifile | awk 'BEGIN {k=0;}; $1~/mpr/{k=1}; END {print k;};'`) then
            echo reorient MPRAGE "$item"/"$niifile"
            fslswapdim $niifile z -x -y `basename $niifile .nii`_reorient.nii
         else
            echo reorient bold/anat/fieldmap "$item"/"$niifile"
            fslswapdim $niifile x -y z `basename $niifile .nii`_reorient.nii
         endif
    fslorient -forceradiological `basename $niifile .nii`_reorient.nii

    end
    cd ../
 end
 cd ../
end

