#!/bin/csh -f
# $Header$
# $Log$
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
set zpdbold = ""
@ k = 1
while ($k <= ${#fcbold})
	set zpdbold = ($zpdbold `echo $fcbold[$k] | awk '{printf ("%03d",$1)}'`)
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

#####################
# virtual concatenate
#####################
CONC:
echo virtually concatenate atlas-transformed resampled BOLD 4dfp stacks `date`
set lst = "$subject"_faln_dbnd_xr3d_222_t88.lst
if (-e $lst) /bin/rm $lst
touch $lst
@ k = 1
while ($k <= ${#zpdbold})	    
	echo bold/$zpdbold[$k]/$subject"_bld"$zpdbold[$k]_$runid[$k]"_faln_dbnd_xr3d_222_t88" >> $lst
	@ k++
end

conc_4dfp   $subject"_faln_dbnd_xr3d_222_t88" -l$lst
echo	cat $subject"_faln_dbnd_xr3d_222_t88".conc
	cat $subject"_faln_dbnd_xr3d_222_t88".conc

if (! -e fcMRI) mkdir fcMRI
/bin/mv $subject"_faln_dbnd_xr3d_222_t88".* fcMRI

pushd fcMRI				# into fcMRI

##############
# spatial blur
##############
BLUR:
echo	gauss_4dfp $subject"_faln_dbnd_xr3d_222_t88".conc $blur
if ($G)	gauss_4dfp $subject"_faln_dbnd_xr3d_222_t88".conc $blur

##########################
# temporal bandpass filter
##########################
BANDPASS:
set blurstr = g`echo $blur | awk '{print int(10*$1+.5)}'`
echo	bandpass_4dfp -n$skip $subject"_faln_dbnd_xr3d_222_t88_"$blurstr".conc" $TR_vol -bh.08 -oh2 -E -tbpss
if ($G)	bandpass_4dfp -n$skip $subject"_faln_dbnd_xr3d_222_t88_"$blurstr".conc" $TR_vol -bh.08 -oh2 -E -tbpss

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
	set F = $subject"_bld"$zpdbold[$k]_$runid[$k]"_faln_dbnd_xr3d"
	awk '$1!~/#/{for (i = 2; i <= 7; i++) printf ("%10s", $i); printf ( "\n" );}' $movdir/$F.rdat >! $$.0
	awk '$1!~/#/{for (i = 2; i <= 7; i++) printf ("%10s", $i); printf ( "\n" );}' $movdir/$F.ddat >! $$.1
	paste $$.0 $$.1 >! $F.rddat
	cat $F.rddat | nawk -f $RELEASE/trendout.awk >> $regr_output

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
WB:
qnt_4dfp -s -d -f$format $subject"_faln_dbnd_xr3d_222_t88_"$blurstr"_bpss.conc" $REFDIR/regions/young6+6_atrophy_avg_222_brain \
	| awk '$1!~/#/{printf("%10.4f%10.4f\n", $2, $3)}' >! $subject"_WB_regressor_dt".dat

########################################################################
# make ventricle and bilateral white matter regressors (with) derivative
########################################################################
VENT_WM:
qnt_4dfp -s -d -f$format $subject"_faln_dbnd_xr3d_222_t88_"$blurstr"_bpss".conc $REFDIR/regions/bilateral_ventricles \
	| awk '$1!~/#/{printf("%10.4f%10.4f\n", $2, $3)}' >! $$.1
qnt_4dfp -s -d -f$format $subject"_faln_dbnd_xr3d_222_t88_"$blurstr"_bpss".conc $REFDIR/regions/bilateral_WM \
	| awk '$1!~/#/{printf("%10.4f%10.4f\n", $2, $3)}' >! $$.2
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
echo	glm_4dfp $format $subject"_regressors".dat $subject"_faln_dbnd_xr3d_222_t88_"$blurstr"_bpss".conc -rresid -o
if ($G)	glm_4dfp $format $subject"_regressors".dat $subject"_faln_dbnd_xr3d_222_t88_"$blurstr"_bpss".conc -rresid -o
echo	var_4dfp -s -f$format $subject"_faln_dbnd_xr3d_222_t88_"$blurstr"_bpss_resid.conc"
if ($G)	var_4dfp -s -f$format $subject"_faln_dbnd_xr3d_222_t88_"$blurstr"_bpss_resid.conc"
 

##############################################
# make subject-specific mask of defined voxels
##############################################
echo	compute_defined_4dfp $subject"_faln_dbnd_xr3d_222_t88.conc"
if ($G)	compute_defined_4dfp $subject"_faln_dbnd_xr3d_222_t88.conc"

popd				# out of fcMRI
echo $program completed for subject $subject
popd				# out of $subject
exit
