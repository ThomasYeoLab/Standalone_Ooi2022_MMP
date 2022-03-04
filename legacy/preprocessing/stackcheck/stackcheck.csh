#!/bin/csh -f
# $Header: v 1.3 2007/08/01 13:38:22 mtt24 Exp $
# $Author: mtt24 $ $Date: 2007/08/01 13:38:22 $

set VERSION = '$Id: stackcheck.csh,v 1.0 2008/03/10 13:38:22 mtt24 Exp $'

if($#argv == 0) then
  echo ""
  echo "USAGE: stackcheck.csh SUBJID"
  echo ""
  echo "Version: " $VERSION
  exit 0;
endif


set program = 'stackcheck.csh'
set subject = $1
echo $1
pwd
if (! -d $subject) then
	echo $program": directory" $subject found
	exit -1
endif

pushd $subject				# into $subject


set prmfile = scripts/$subject.params


if (! -e $prmfile) then
	echo $program": "$prmfile not found
	exit -1
endif
source $prmfile
set zpdbold = ""

@ k = 1
while ($k <= ${#bold})
	set zpdbold = ($zpdbold `echo $bold[$k] | awk '{printf ("%03d",$1)}'`)
	@ k++
end

@ k = 1
while ($k <= ${#bold})	    
	set file1 = "bold/$zpdbold[$k]/{$subject}_bld{$zpdbold[$k]}_rest_reorient_skip_faln_mc_atl.nii.gz" 
	stackcheck_nifti -snr -mean -stdev -zip -i $file1 
	stackcheck_nifti -quiet -thresh 150 -mask -zip -report -i $file1 
	
	@ k++
end

popd

cd $subject
cd bold
@ k = 1
while ($k <= ${#bold})	
set output1 = "$zpdbold[$k]/{$subject}_bld{$zpdbold[$k]}_rest_reorient_skip_faln_mc_atl_mask.nii.gz"  
set output2 = "$zpdbold[$k]/{$subject}_bld{$zpdbold[$k]}_rest_reorient_skip_faln_mc_atl_mean.nii.gz"
set output3 = "$zpdbold[$k]/{$subject}_bld{$zpdbold[$k]}_rest_reorient_skip_faln_mc_atl_snr.nii.gz"
set output4 = "$zpdbold[$k]/{$subject}_bld{$zpdbold[$k]}_rest_reorient_skip_faln_mc_atl_sd.nii.gz"
set output5 = "$zpdbold[$k]/{$subject}_bld{$zpdbold[$k]}_rest_reorient_skip_faln_mc_atl.report"

mv $output1 "../qc"
mv $output2 "../qc"
mv $output3 "../qc"
mv $output4 "../qc"
mv $output5 "../qc"
@ k++
end

cd ../..

exit 0;
