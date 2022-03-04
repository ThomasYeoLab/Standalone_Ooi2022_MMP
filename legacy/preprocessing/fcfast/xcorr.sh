#!/bin/tcsh -f
# $Header: /ncf/tools/mtt24/nexus-tools/bin/xcorr.sh,v 1.3 2008/04/06 17:38:22 mtt24 Exp $
# $Author: mtt24 $ $Date: 2008/01/18 13:38:22 $

set VERSION = '$Id: xcorr.sh,v 1.0 2008/01/18 12:35:22 mtt24 Exp $'

if($#argv == 0) then
  echo ""
  echo "USAGE: xcorr.sh -s 070519_4TT00247 -thresh 0.25 -mask 711-2V_mask_on_N12Trio_avg152T1.nii.gz"
  echo ""
  echo "Version: " $VERSION
  exit 0;
endif



set program = 'xcorr.sh'

set cluster_flag = 0;
set weight_flag = 0;
set cmdline = ($argv);
while( $#argv != 0 )

  set flag = $argv[1]; shift;
  switch($flag)

    case "-s":
      if ( $#argv == 0 ) echo "ERROR: flag $flag requires one argument" exit 1;
      set subject = `basename $argv[1]`; shift;
      breaksw
	
    case "-thresh":
      if ( $#argv == 0 ) echo "ERROR: flag $flag requires one argument" exit 1;
      set threshval = $argv[1]; shift;
      breaksw;
    
    case "-mask":
      if ( $#argv == 0 ) echo "ERROR: flag $flag requires one argument" exit 1;
      set mask = $argv[1]; shift;
      breaksw;

    case "-cluster":
      set cluster_flag = 1;
      breaksw;

    case "-weight":
      set weight_flag = 1;
      breaksw;

    default:
      echo ERROR: Flag $flag unrecognized. 
      echo $cmdline
      exit 1
      breaksw
  endsw

end  	
     
if (! -d $subject) then
	echo $program": directory" $subject not found
	exit -1
endif
pushd $subject

set prmfile = scripts/$subject.params.bak


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
set file1 = "bold/$zpdbold[$k]/${subject}_bld${zpdbold[$k]}_rest_reorient_skip_faln_mc_atl_g7_bpss_resid.nii.gz"
	 
	 
         if ( $cluster_flag == 1 && $weight_flag == 0) then
		bsub -o bjobs.log -P ${subject}_spcorrw "spcorrw -i $file1 -mask $mask -thresh $threshval"
	 endif
	 
	 if ( $cluster_flag == 0 && $weight_flag == 0) then
	        spcorrw -i $file1 -mask $mask -thresh $threshval &
		#echo "Starting to sleep"		
		#sleep 20 &
         endif
         
         if ( $cluster_flag == 1 && $weight_flag == 1) then 
		bsub -o bjobs.log -P ${subject}_spcorrw "spcorrw -i $file1 -mask $mask -thresh $threshval -w"
         endif
	 
	 if ( $cluster_flag == 0 && $weight_flag == 1) then 
		spcorrw -i $file1 -mask $mask -thresh $threshval -w &
         endif	  
@ k++
end

mkdir bc

endif

popd

	
cd $subject
if ( $cluster_flag == 1) then
	 bjobs -P ${subject}_spcorrw | awk '{print $1}' >> bjobids.txt
endif

if ( $cluster_flag == 0) then
	ps | grep spcorrw | awk '{print $1}' >> childps.txt
endif

cd bold
set bclist = ${subject}_bc.txt
if (-e $bclist) rm $bclist
touch $bclist
@ k = 1
while ($k <= ${#bold})	
set output = "$zpdbold[$k]/${subject}_bld${zpdbold[$k]}_rest_reorient_skip_faln_mc_atl_g7_bpss_resid_bc_msk_thr${threshval}.nii.gz"  
	while (! -e $output)
		sleep 1
	end
if (-e $output) then
	echo "${subject}_bld${zpdbold[$k]}_rest_reorient_skip_faln_mc_atl_g7_bpss_resid_bc_msk_thr${threshval}.nii.gz" >> $bclist
endif
mv $output "../bc"
@ k++
end
mv $bclist "../bc"
cd ../..
echo "Whole brain correlation computed for all bold runs!"
exit 0;	

