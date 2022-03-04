#!/bin/csh -f
# $Header$
# $Log$
# 07/06/08 added -D to qnt_4dfp -jv
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
set prmfile = scripts/$subject.params
if (! -e $prmfile) then
	echo $program": "$prmfile not found
	exit -1
endif
source $prmfile
########################################
# compute zero-padded bold study numbers 
########################################
set RELEASE = $CODE_DIR/tools/avi
set BIN = $CODE_DIR/tools/avi

set zpdbold = ""
@ k = 1
while ($k <= ${#fcbold})
	set zpdbold = ($zpdbold `echo $fcbold[$k] | awk '{printf ("%03d",$1)}'`)
	@ k++
end

if (! $?BIN) then
	echo executables directory not defined
	exit -1
endif

set movdir = $cwd/movement
if (! -e $movdir) then
	$program": "$movdir not found
	exit -1
endif


#####################
# virtual concatenate
#####################
CONC:
echo virtually concatenate atlas-transformed resampled BOLD nifti stacks `date`
set lst = $subject"_"$ppstr.txt
if (-e $lst) /bin/rm $lst
touch $lst
@ k = 1
while ($k <= ${#zpdbold})	    
	echo $PWD/bold/$zpdbold[$k]/$subject"_bld"$zpdbold[$k]_$runid[$k]"_"$ppstr"" >> $lst
	@ k++
end

set subjdir = $PWD

#conc_4dfp   $subject"_"$ppstr"" -l$lst
#echo	cat $subject"_"$ppstr"".conc
#	cat $subject"_"$ppstr"".conc

if (! -e fcMRI) mkdir fcMRI
/bin/mv $subject"_"$ppstr"".* fcMRI

pushd fcMRI				# into fcMRI


##############
# spatial blur
##############
BLUR:
echo	gauss_nifti -list $subject"_"$ppstr"".txt $blur
if ($G)	gauss_nifti -list $subject"_"$ppstr"".txt $blur


##########################
# temporal bandpass filter
##########################
BANDPASS:
set blurstr = g`echo $blur | awk '{print int(10*$1+.5)}'`
set lst2 = $subject"_"$ppstr"_"$blurstr.txt
if (-e $lst2) /bin/rm $lst2
touch $lst2
@ k = 1
while ($k <= ${#zpdbold})	    
	echo $subjdir/bold/$zpdbold[$k]/$subject"_bld$zpdbold[$k]_$runid[$k]"_"$ppstr"_"$blurstr" >>$lst2
	@ k++
end
echo	bandpass_nifti -n$skip -list $subject"_"$ppstr"_"$blurstr".txt" $TR_vol -bh$bh -oh$oh -bl$bl -ol$ol -E -tbpss
if ($G)	bandpass_nifti -n$skip -list $subject"_"$ppstr"_"$blurstr".txt" $TR_vol -bh$bh -oh$oh -bl$bl -ol$ol -E -tbpss


############################################
# make movement regressors for each BOLD run
############################################
MOVEMENT:
set regr_output = $subject"_mov_regressor".dat
if (-e $regr_output) /bin/rm $regr_output
touch $regr_output
set format = ""
@ k = 1
while ($k <= ${#zpdbold})	    
	set F = $subject"_bld"$zpdbold[$k]_$runid[$k]_$mvstr
	awk '$1!~/#/{for (i = 2; i <= 7; i++) printf ("%10s", $i); printf ( "\n" );}' $movdir/$F.rdat >! $$.0
	awk '$1!~/#/{for (i = 2; i <= 7; i++) printf ("%10s", $i); printf ( "\n" );}' $movdir/$F.ddat >! $$.1
	paste $$.0 $$.1 >! $F.rddat
	cat $F.rddat | awk -f $RELEASE/trendout.awk >> $regr_output
	/bin/rm $F.rddat

################################
# compile frames to count format
################################
	@ n = `wc $$.0 | awk '{print $1}'`
	@ m = $n - $skip
	set format = $format$skip"x"$m"+"
	@ k++
end
echo format=$format

##################################################
# make the whole brain regressor (with derivative)
##################################################
set lst3 = $subject"_"$ppstr"_"$blurstr"_bpss".txt
if (-e $lst3) /bin/rm $lst3
touch $lst3
@ k = 1
while ($k <= ${#zpdbold})	    
echo $subjdir/bold/$zpdbold[$k]/$subject"_bld$zpdbold[$k]_$runid[$k]"_"$ppstr"_"$blurstr"_"bpss" >> $lst3
	@ k++
end
WB:
qnt_nifti -s -d -D -f$format -list $subject"_"$ppstr"_"$blurstr"_bpss.txt" $wbreg \
        | awk '$1!~/#/{printf("%10.4f%10.4f\n", $2, $3)}' >! $subject"_WB_regressor_dt".dat

########################################################################
# make ventricle and bilateral white matter regressors (with) derivative
########################################################################
VENT_WM:
qnt_nifti -s -d -D -f$format -list $subject"_"$ppstr"_"$blurstr"_bpss".txt $ventreg \
	| awk '$1!~/#/{printf("%10.4f%10.4f\n", $2, $3)}' >! $$.1
qnt_nifti -s -d -D -f$format -list $subject"_"$ppstr"_"$blurstr"_bpss".txt $wmreg \
	| awk '$1!~/#/{printf("%10.4f%10.4f\n", $2, $3)}' >! $$.2

paste $$.1 $$.2 >! $subject"_vent_wm_dt".dat

/bin/rm $$.[012]


###############################
# paste all regressors together
###############################
PASTE:
paste $subject"_mov_regressor".dat $subject"_WB_regressor_dt".dat $subject"_vent_wm_dt".dat >! $subject"_regressors".dat	

###################################################
# run glm_nifti to regress out movement, WB, vent_wm
###################################################
GLM_NIFTI:
echo	glm_nifti $format $subject"_regressors".dat -list $subject"_"$ppstr"_"$blurstr"_bpss".txt -rresid -o
if ($G)	glm_nifti $format $subject"_regressors".dat -list $subject"_"$ppstr"_"$blurstr"_bpss".txt -rresid -o

set lst4 = $subject"_"$ppstr"_"$blurstr"_bpss_resid".txt
if (-e $lst3) /bin/rm $lst4
touch $lst4
@ k = 1
while ($k <= ${#zpdbold})	    
echo $subjdir/bold/$zpdbold[$k]/$subject"_bld$zpdbold[$k]_$runid[$k]"_"$ppstr"_"$blurstr"_"bpss_resid" >> $lst4
	@ k++
end

echo	var_nifti -s -f$format -list $subject"_"$ppstr"_"$blurstr"_bpss_resid.txt"
if ($G)	var_nifti -s -f$format -list $subject"_"$ppstr"_"$blurstr"_bpss_resid.txt"

popd				# out of fcMRI
echo $program completed for subject $subject
popd				# out of $subject
exit


##############################################
# make subject-specific mask of defined voxels
##############################################
#echo	compute_defined_4dfp $subject"_"$ppstr".conc"
#if ($G)	compute_defined_4dfp $subject"_"$ppstr".conc"

#popd				# out of fcMRI
#echo $program completed for subject $subject
#popd				# out of $subject
#exit
