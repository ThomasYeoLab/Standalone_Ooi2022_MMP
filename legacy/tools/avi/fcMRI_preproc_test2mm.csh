#!/bin/csh -f
# $Header$
# $Log$
# 06/08/07 added -D to qnt_4dfp -jv
# 07/18/07 changes to accept multi-session subjects
set FCMRI = 1
set echo 
set idstr = '$Id$'
#########################################################################################
# This script runs the fcMRI preprocessing (whch follows initial preprocessing).	#
# Subject-specific parameters are read in scripts/$subject/params.			#
#########################################################################################

echo $idstr
set program = $0; set program = $program:t
if ($#argv < 1) then
	echo $program": subject not specified"
	exit -1
endif

set subject = $1
if (! -d $subject) then
	echo $program": directory" $subject not found
	exit -1
endif

pushd $subject				# into $subject
set prmfile = scripts/${subject}_2mm.params
if (! -e $prmfile) then
	echo $program": "$prmfile not found
	exit -1
endif
source $prmfile

########################################
# compute zero-padded bold study numbers 
########################################
set zpdbold1 = ""
@ k = 1
while ($k <= ${#fcbold1})
	set zpdbold1 = ($zpdbold1 `echo $fcbold1[$k] | nawk '{printf ("%03d",$1)}'`)
	@ k++
end

set zpdbold2 = ""
@ k = 1
while ($k <= ${#fcbold2})
	set zpdbold2 = ($zpdbold2 `echo $fcbold2[$k] | nawk '{printf ("%03d",$1)}'`)
	@ k++
end

if (! $?RELEASE) then
	echo executables directory not defined
	exit -1
endif

set movdir = $cwd/movement
if (! -e $movdir) then
	$program": "$movdir not found
	exit -1
endif

#################
# mask bold files
#################
pushd $wrkdir/$subsets[1]/bold
    @ k = 1
    while ($k <= ${#zpdbold1})
	pushd $zpdbold1[$k]
	    zero_lt_4dfp 50 $subsets[1]"_bld"$zpdbold1[$k]_$runid1[$k]"_"$ppstr $subsets[1]"_bld"$zpdbold1[$k]_$runid1[$k]"_"$ppstr"_mskt"
	popd
	@ k++
    end
popd

pushd $wrkdir/$subsets[2]/bold
    @ k = 1
    while ($k <= ${#zpdbold2})
	pushd $zpdbold2[$k]
	    zero_lt_4dfp 50 $subsets[2]"_bld"$zpdbold2[$k]_$runid2[$k]"_"$ppstr $subsets[2]"_bld"$zpdbold2[$k]_$runid2[$k]"_"$ppstr"_mskt"
	popd
	@ k++
    end
popd

#####################
# virtual concatenate
#####################
CONC:
echo virtually concatenate atlas-transformed resampled BOLD 4dfp stacks `date`
set lst = $subject"_"$ppstr.lst
if (-e $lst) /bin/rm $lst
touch $lst
@ k = 1
while ($k <= ${#zpdbold2})
	echo $wrkdir/$subsets[2]/bold/$zpdbold2[$k]/$subsets[2]"_bld"$zpdbold2[$k]_$runid2[$k]"_"$ppstr"_mskt" >> $lst
	@ k++
end

@ k = 1
while ($k <= ${#zpdbold1})
	echo $wrkdir/$subsets[1]/bold/$zpdbold1[$k]/$subsets[1]"_bld"$zpdbold1[$k]_$runid1[$k]"_"$ppstr"_mskt" >> $lst
	@ k++
end

conc_4dfp   $subject"_"$ppstr"" -l$lst -w
echo	cat $subject"_"$ppstr"".conc
	cat $subject"_"$ppstr"".conc

if (! -e fcMRI) mkdir fcMRI
/bin/mv $subject"_"$ppstr"".* fcMRI

pushd fcMRI				# into fcMRI
##############
# spatial blur
##############
BLUR:
echo	gauss_4dfp $subject"_"$ppstr.conc $blur
if ($G)	gauss_4dfp $subject"_"$ppstr.conc $blur

##########################
# temporal bandpass filter
##########################
BANDPASS:
set blurstr = g`echo $blur | nawk '{print int(10*$1+.5)}'`
echo	bandpass_4dfp -n$skip $subject"_"$ppstr"_"$blurstr".conc" $TR_vol -bh$bh -oh$oh -bl$bl -ol$ol -E -tbpss
if ($G)	bandpass_4dfp -n$skip $subject"_"$ppstr"_"$blurstr".conc" $TR_vol -bh$bh -oh$oh -bl$bl -ol$ol -E -tbpss

############################################
# make movement regressors for each BOLD run
############################################
MOVEMENT:
set regr_output = $subject"_mov_regressor".dat
if (-e $regr_output) /bin/rm $regr_output
touch $regr_output
set format = ""
@ k = 1
while ($k <= ${#zpdbold1})	    
	set F = $subsets[1]"_bld"$zpdbold1[$k]_$runid1[$k]_$mvstr
	nawk '$1!~/#/{for (i = 2; i <= 7; i++) printf ("%10s", $i); printf ( "\n" );}' $movdir/$F.rdat >! $$.0
	nawk '$1!~/#/{for (i = 2; i <= 7; i++) printf ("%10s", $i); printf ( "\n" );}' $movdir/$F.ddat >! $$.1
	paste $$.0 $$.1 >! $F.rddat
	cat $F.rddat | nawk -f $RELEASE/trendout.awk >> $regr_output
	/bin/rm $F.rddat

################################
# compile frames to count format
################################
	@ n = `wc $$.0 | nawk '{print $1}'`
	@ m = $n - $skip
	set format = $format$skip"x"$m"+"
	@ k++
end

@ k = 1
while ($k <= ${#zpdbold2})	    
	set F = $subsets[2]"_bld"$zpdbold2[$k]_$runid2[$k]_$mvstr
	nawk '$1!~/#/{for (i = 2; i <= 7; i++) printf ("%10s", $i); printf ( "\n" );}' $movdir/$F.rdat >! $$.0
	nawk '$1!~/#/{for (i = 2; i <= 7; i++) printf ("%10s", $i); printf ( "\n" );}' $movdir/$F.ddat >! $$.1
	paste $$.0 $$.1 >! $F.rddat
	cat $F.rddat | nawk -f $RELEASE/trendout.awk >> $regr_output
	/bin/rm $F.rddat

################################
# compile frames to count format
################################
	@ n = `wc $$.0 | nawk '{print $1}'`
	@ m = $n - $skip
	set format = $format$skip"x"$m"+"
	@ k++
end

echo format=$format

##################################################
# make the whole brain regressor (with derivative)
##################################################
WB:
qnt_4dfp -s -d -D -f$format $subject"_"$ppstr"_"$blurstr"_bpss.conc" $wbreg \
	| nawk '$1!~/#/{printf("%10.4f%10.4f\n", $2, $3)}' >! $subject"_WB_regressor_dt".dat

########################################################################
# make ventricle and bilateral white matter regressors (with) derivative
########################################################################
VENT_WM:
qnt_4dfp -s -d -D -f$format $subject"_"$ppstr"_"$blurstr"_bpss".conc $ventreg \
	| nawk '$1!~/#/{printf("%10.4f%10.4f\n", $2, $3)}' >! $$.1
qnt_4dfp -s -d -D -f$format $subject"_"$ppstr"_"$blurstr"_bpss".conc $wmreg \
	| nawk '$1!~/#/{printf("%10.4f%10.4f\n", $2, $3)}' >! $$.2
paste $$.1 $$.2 >! $subject"_vent_wm_dt".dat

/bin/rm $$.[012]
###############################
# paste all regressors together
###############################
PASTE:
paste $subject"_mov_regressor".dat $subject"_WB_regressor_dt".dat $subject"_vent_wm_dt".dat >! $subject"_regressors".dat	

###################################################
# run glm_4dfp to regress out movement, WB, vent_wm
###################################################
GLM_4DFP:
echo	glm_4dfp $format $subject"_regressors".dat $subject"_"$ppstr"_"$blurstr"_bpss".conc -rresid -o
if ($G)	glm_4dfp $format $subject"_regressors".dat $subject"_"$ppstr"_"$blurstr"_bpss".conc -rresid -o
echo	var_4dfp -s -f$format $subject"_"$ppstr"_"$blurstr"_bpss_resid.conc"
if ($G)	var_4dfp -s -f$format $subject"_"$ppstr"_"$blurstr"_bpss_resid.conc"
 

##############################################
# make subject-specific mask of defined voxels
##############################################
echo	compute_defined_4dfp $subject"_"$ppstr".conc"
if ($G)	compute_defined_4dfp $subject"_"$ppstr".conc"

popd				# out of fcMRI
echo $program completed for subject $subject
popd				# out of $subject
exit
