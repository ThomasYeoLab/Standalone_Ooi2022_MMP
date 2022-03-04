#!/bin/csh -f
# $Header$
# $Log$
set idstr = '$Id$'
#########################################################################
# This 4dfp script processes raw BOLD and MPRAGE data for one subject	#
# using standard Washington University executables. Computes		#
# a bold atlas transform in the anat subdirectory and 222 space atlas	#
# transformed volumetric timeseries in each bold/$bold[$k] directory.	#
#########################################################################

echo $idstr
set program = $0; set program = $program:t
if ($#argv < 1) then
	echo $program": subject not specified"
	exit -1
endif

set subject	= $1
set wrkdir	= $cwd
set rawdir	= $cwd/$subject/raw

echo first stage preprocessiing $subject `date`
if (! ${?G}) @ G = 1		# $G == 0 is test mode


if (! -d $subject) then
	echo $program": directory" $subject not found
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

        set zpdmprs = ""
        @ k = 1
        while ($k <= ${#mprs})
            set zpdmprs = ($zpdmprs `echo $mprs[$k] | awk '{printf ("%03d",$1)}'`)
            @ k++
        end

	if (! -d movement) mkdir movement
	set movdir = $cwd/movement

      	if (! -d anat) mkdir anat
        set anatdir = $cwd/anat

        if (! -d bold) mkdir bold
	pushd bold				# into bold
	@ k = 1
	while ($k <= ${#bold})
		echo $k
		if (! -d $zpdbold[$k]) mkdir $zpdbold[$k]
                pushd $zpdbold[$k]		# into $zpdbold[$k]
		echo "converting dicom to 4dfp..." 
		echo	dcm_to_4dfp -b $subject"_"study$zpdbold[$k] $rawdir/$dcmroot"-"$bold[$k]-"*"
		if ($G)	dcm_to_4dfp -b $subject"_"study$zpdbold[$k] $rawdir/$dcmroot"-"$bold[$k]-*
                if ($status) then
                    echo "$program" dcm_to_4dfp conversion failed bold run $bold[$k]
                    exit -1
                endif
		set prefix = $subject"_"bld$zpdbold[$k]_$runid[$k]
		echo study $zpdbold[$k] is $prefix
		
		echo	unpack_4dfp -nx$num_x -ny$num_y -V $subject"_"study$zpdbold[$k] $prefix
		if ($G)	unpack_4dfp -nx$num_x -ny$num_y -V $subject"_"study$zpdbold[$k] $prefix
 				
		echo	frame_align_4dfp $prefix $skip -TR_vol $TR_vol -TR_slc $TR_slc -d 0
		if ($G)	frame_align_4dfp $prefix $skip -TR_vol $TR_vol -TR_slc $TR_slc -d 0

		echo	deband_4dfp -n$skip $prefix"_faln"
		if ($G)	deband_4dfp -n$skip $prefix"_faln"		      
		popd				# out of $zpdbold[$k]
		@ k++
	end
        touch $subject"_xr3d".lst
	touch $subject"_frm1".lst
	@ k = 1
	while ($k <= ${#bold})
		echo $zpdbold[$k]/$subject"_bld"$zpdbold[$k]_$runid[$k]"_faln_dbnd" >> $subject"_xr3d".lst
		echo $zpdbold[$k]/$subject"_bld"$zpdbold[$k]_$runid[$k]"_faln_dbnd_xr3d" 1 >> $subject"_frm1".lst
		@ k++
	end

#########################################
# movement correct within and across runs
#########################################
	echo	cat $subject"_xr3d".lst
	if ($G)	cat $subject"_xr3d".lst
	echo	cross_realign3d_4dfp -n$skip -qv$normode -l$subject"_xr3d".lst
	if ($G)	cross_realign3d_4dfp -n$skip -qv$normode -l$subject"_xr3d".lst

###################
# movement analysis
###################
	@ k = 1
	while ($k <= ${#bold})
		pushd $zpdbold[$k]		# into $zpdbold[$k]
		echo	mat2dat -RD "*_xr3d".mat
		if ($G)	mat2dat -RD *_xr3d.mat
	
		echo	/bin/mv "*_xr3d"."*"dat	$movdir/
		if ($G)	/bin/mv *_xr3d.*dat	$movdir/
		@ k++
		popd				# out of $zpdbold[$k]
	end

######################################
# make EPI first frame (anatomy) image
######################################
        echo	cat $subject"_frm1".lst                                               
	if ($G)	cat $subject"_frm1".lst                                               
	echo	paste_4dfp -p1 $subject"_frm1".lst $subject"_frm1_ave"      
	if ($G)	paste_4dfp -p1 $subject"_frm1".lst $subject"_frm1_ave"      
	    
	echo	4dfptoanalyze $subject"_frm1_ave"                         
	if ($G)	4dfptoanalyze $subject"_frm1_ave"                         

	echo	/bin/mv "$subject"_frm1_ave"*" $anatdir/
	if ($G)	/bin/mv "$subject"_frm1_ave*   $anatdir/
        
        popd					# out of bold
        
######################
# make MP-RAGE average
######################
	set mprave = $subject"_mpr_n"${#mprs}
	set mprlst = ""
	pushd anat				# into anat
	@ k = 1
	while ($k <= ${#mprs})
		set mprlst = ($mprlst $subject"_"mpr$zpdmprs[$k])
		if (! -d $zpdmprs[$k]) mkdir $zpdmprs[$k]
		pushd $zpdmprs[$k]		# into $zpdmprs[$k]
		echo "converting dicom to 4dfp..."
		echo	dcm_to_4dfp -b $subject"_"mpr$zpdmprs[$k] $rawdir/$dcmroot"-"$mprs[$k]-"*"
		if ($G)	dcm_to_4dfp -b $subject"_"mpr$zpdmprs[$k] $rawdir/$dcmroot"-"$mprs[$k]-*
                if ($status) then
                    echo "$program": dcm_to_4dfp conversion failed mprage $mprs[$k]
                    exit -1
                endif
		popd				# out of $zpdmprs[$k]
		@ k++
        end

#####################################################################
# symbolically link $zpdmprs into anat parent directory and make $mprave
#####################################################################
if ($G) then
        @ k = 1
	while ($k <= ${#zpdmprs})
		foreach x ($zpdmprs[$k]/$subject"_"mpr$zpdmprs[$k].4dfp*)
			ln -s $x .
		end
		@ k++
        end
	echo	avgmpr_4dfp $mprlst $mprave $target useold
	if ($G)	avgmpr_4dfp $mprlst $mprave $target useold
endif

##########################################
# mv T88 transformed data to T88 directory
##########################################
	if (! -e T88) mkdir T88
	foreach O (222 111)
		echo	4dfptoanalyze $mprave"_"$O"_t88"
		if ($G)	4dfptoanalyze $mprave"_"$O"_t88"
		echo	/bin/mv $mprave"_"$O"*" T88/
		if ($G)	/bin/mv $mprave"_"$O*   T88/
	end

#########################
# compute atlas transform
#########################
	echo compute atlas transform `date`
	echo	epi2mpr2atl1_4dfp $subject"_frm1_ave" $subject"_"mpr$zpdmprs[1] useold $target
	if ($G) epi2mpr2atl1_4dfp $subject"_frm1_ave" $subject"_"mpr$zpdmprs[1] useold $target
	popd					# out of anat

###################################################################
# make cross-realigned atlas-transformed resampled BOLD 4dfp stacks
###################################################################
	set t4file = $cwd/anat/"$subject"_frm1_ave_to_"$target"_t4
	if (! -e $t4file) then
		echo "$t4file" not present
		if ($G) exit -1
	endif

	echo make cross-realigned atlas-transformed resampled BOLD 4dfp stacks `date`
	pushd bold				# into bold
	@ k = 1
	while ($k <= ${#bold})	    
		pushd $zpdbold[$k]		# into $zpdbold[$k]
		echo	normalize_4dfp $subject"_bld"$zpdbold[$k]_$runid[$k]"_faln_dbnd_r3d_avg"
		if ($G)	normalize_4dfp $subject"_bld"$zpdbold[$k]_$runid[$k]"_faln_dbnd_r3d_avg"

		set file = $subject"_bld"$zpdbold[$k]_$runid[$k]"_faln_dbnd_r3d_avg_norm".4dfp.img.rec
		set f = 1.0; if (-e $file) set f = `head $file | awk '/original/{print 1000/$NF}'`
		echo	t4_xr3d_4dfp $t4file $subject"_bld"$zpdbold[$k]_$runid[$k]"_faln_dbnd" -axr3d_222_t88 -v$normode -O222 -c$f
		if ($G)	t4_xr3d_4dfp $t4file $subject"_bld"$zpdbold[$k]_$runid[$k]"_faln_dbnd" -axr3d_222_t88 -v$normode -O222 -c$f
		popd				# outof $zpdbold[$k]
		@ k++
	end
      	popd					# out of bold

echo $program completed initial preprocessing of $subject
popd						# out of $subject
exit




