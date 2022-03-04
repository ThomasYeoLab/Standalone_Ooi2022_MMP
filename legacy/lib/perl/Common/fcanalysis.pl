#!/usr/bin/perl
# fcanalysis.pl

use strict;
use Getopt::Long;

my $sid;
my %options;
my @seed;
my $seedstr;
my $scriptfile;
my $regdir;
my @regname;
my $regstr;
my $newstr;
my $fcMRIdir;
my $bool;
my $files;
my $format;
my @format;
my $frames;
my $skip;
if (@ARGV < 1){usage();}
GetOptions(\%options, "id=s", "regdir=s", "seed");

if ($options{id}){ $sid = $options{id};}
if ($options{regdir}){ $regdir = $options{regdir};}
if ($options{seed}){
push @seed, $_ foreach @ARGV;

}
for (my $i = 0; $i <= $#seed; $i++){
my $oldstr = $seed[$i];
$_ = $oldstr;
if ($_ =~ /.nii.gz/){
s/.nii.gz/ /g;
}
if ($_ =~ /.nii/){
s/.nii/ /g;
}
$regname[$i] = $_;
$newstr = "\$reg_dir/$oldstr";
$seed[$i] = $newstr;

}
if ($options{seed}) {
$seedstr = join(" ",@seed);
$regstr = join(" ",@regname);
}
print "$seedstr\n";
print "$regstr\n";
chomp($seedstr);
chomp($regstr);


#generate format for frames to count
$fcMRIdir = "$sid/fcMRI";
$skip = 0;
opendir DH, "$fcMRIdir" or die "Error: directory '$fcMRIdir' does not exist in the file system.\n";
$bool = 0;
$files = "${sid}_reorient_skip_faln_mc_atl.txt";
while ($_ = readdir(DH)){

if ($_ eq "$files"){$bool = 1; last;}

}
if ($bool == 1) {print "FOUND: $files\n";}
if ($bool == 0) {print "Cannot read '$files' in directory '$fcMRIdir': change permission settings.\n"; exit;}
closedir DH;
chdir("$fcMRIdir");
open(OUTPUT, $files) or die "Could not open file $files for reading: %!\n";
while (<OUTPUT>){
my $x = "x";
my $m = '+';
$frames = `fslnvols $_`;
chomp($frames);
$format = "$skip$x$frames$m";
push @format, $format;
}
close OUTPUT;
$format = join("",@format);
print "$format\n";
chdir("../../");

#Generate fcMRI_analysis_nifti.csh script with subject ID and seeds specified

$scriptfile = "$sid\_fcMRI_analysis.csh";
open(OUTPUT, '>', $scriptfile) or die "Could not open file $scriptfile for writing: %!\n";
print OUTPUT
"\#!/bin/csh -f
# \$Header\$
# \$Log\$
set idstr = \'\$Id\$\'

########################################################################################################
##  This program computes a timecourse from a seed region and correlates this ROI with all other voxels
########################################################################################################
ROI:
set echo
set subjects = ($sid)
set wrkdir = \$cwd
set reg_dir = \"$regdir\" 
set region = ($seedstr) 
set regname = ($regstr)
set regnumber = \${#region}
set format = \"$format\"
#goto COMBINE

foreach k (\$subjects)
    pushd \$wrkdir/\$k
        source scripts/\$k\".params\"
	echo \$subject
	if (! -e fcMRI_ANALYSIS) mkdir fcMRI_ANALYSIS
	@ k = 1
	    while (\$k <= \$regnumber)
		echo \$k
		echo \"now running fcMRI for All rest runs\"
		pushd \$wrkdir/\$subject/fcMRI
		    set lst = \$subject\"_\"\$regname[\$k]\".dat\"
		    if (-e \$lst) /bin/rm \$lst; touch \$lst	
		    set file = \$subject\"_\"\$ppstr\"_g7_bpss_resid.txt\"
		    set file2 = \$subject\"_\"\$ppstr\"_g7_bpss_resid\"
		    qnt_nifti -s -list \$file \$region[\$k] | awk \'\$1 !~/#/ {print \$2}\' >> \$lst
		    actmapf_nifti -zu \$format -list \$file -a\$regname[\$k] -w\$lst	
		    imgopr_nifti -r\$file2\"_\"\$regname[\$k]\"_corcoef\" \$file2\"_\"\$regname[\$k] \$file2\"_sd1\"
		    rho2z_nifti \$file2\"_\"\$regname[\$k]\"_corcoef\"
		    /bin/mv \*\$regname[\$k]\* ../fcMRI_ANALYSIS
		popd
	@ k++
	end
    popd
end
exit
";
close OUTPUT;
`chmod 775 $scriptfile`;
sub usage
{
  print "usage: fcanalysis.pl -id 070612_4TT00265 -regdir /ncf/mtt24/seeds -seed ROI_reg6mm_-40_18_48_.nii.gz \n";
  print "options:\n";
  print "-id: specify session ID\n";
  print "-regdir: specify location of the seeds directory \n";
  print "-seed: specify single seed region name or multiple seed region names\n";
  print "example: -seed N12Trio_avg152T1_reg6mm_-40_18_48_.nii.gz N12Trio_avg152T1_reg6mm_40_-18_48_.nii.gz\n";
  exit;
}
