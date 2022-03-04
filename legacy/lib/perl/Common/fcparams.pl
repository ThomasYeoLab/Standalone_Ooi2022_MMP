#!/usr/bin/perl
# $Id: fcparams.pl,v 1.2 2008/09/04 17:35:24 mtt24 Exp $
# $Id: fcparams.pl,v 1.3 2011/03/29 17:35:24 ythomas Exp $

use strict;
use Getopt::Long;

if(@ARGV < 1)
{
	usage();
}

my %options;
my $sid;
my $mpr;
my $epinum = "";
my @bold;
my $boldstr;
my $runtype;
my $TR;
my $inithres;
my $inithresuthr;
my $T1targetimage;
my $T2targetimage;
my $spmprms = "\#";

GetOptions(\%options,	"id=s", 
			"sdir=s", 
			"TR=s",
			"skip=s",
			"mpr=s",
			"epi=s",
			"bold",
			"T1targetimage=s",
			"T2targetimage=s",
			"SPMparams=s");

if($options{T1targetimage})
{
	$T1targetimage = $options{T1targetimage};
	chomp($T1targetimage);
}

if($options{T2targetimage})
{
	$T2targetimage = $options{T2targetimage};
	chomp($T2targetimage);
}

if($options{id}){$sid = $options{id};}
if($options{mpr}){$mpr = $options{mpr};}

if($options{epi})
{
	chomp($options{epi});
	$epinum = $options{epi}; 
	$inithres = "set initial_highres=($epinum)  # t1 weighted EPI";
	$inithresuthr = "set initial_highres_uthr=450";
}
else
{
	$inithres = "";
	$inithresuthr = "";
}

if($options{SPMparams})
{
	$spmprms = $options{SPMparams};
	chomp($spmprms);
	$spmprms = "set spm_normalize_addpath = \"addpath('${spmprms}','-begin');\"";
}

if($options{TR}){$TR = $options{TR};}
if($options{bold}){push @bold, $_ foreach @ARGV;}
if($options{bold})
{
	$boldstr = join(" ", @bold);
	$runtype = "rest " x @bold;
	chop($runtype);
}

my $paramsfile = $sid.".params";

## --- check if sdir is writable
my $sdir = './';

if($options{sdir})
{
	my $BOOL = 0;
	
	opendir DH, $options{sdir} or die "Error: directory $options{sdir} does not exist in the file system.\n";
	
	$sdir = $options{sdir};
	$_ = readdir(DH);
	$BOOL = 1 if -w $_;

	if($BOOL == 0)
	{
		print "Cannot write '$paramsfile' into directory '$options{sdir}': change permission settings.\n"; 
		exit 1;
	}

	closedir DH;
}

chomp($sdir);
chdir($sdir);

## --- generate .params file

open(OUTPUT, '>', $paramsfile) or die "Could not open file $paramsfile for writing: %!\n";


print OUTPUT 
"\#################################################################
# This is a parameter file that lists the specific anatomical
# and functional parameters hat are called upon in the 
# preprocessing and fcMRI scripts.  It should be edited for 
# each subject
#################################################################
$spmprms
set subject=$sid

# Number of frames to delete
set target=\"$T1targetimage\"
set epitarget=\"$T2targetimage\" 
@ skip=$options{skip}
set TR_vol='$TR'
set mprs  	        = ($mpr)

#goto process_FC
########## process:
set qc_folder='qc'                # quality control folder
set slab=0                        # 1 = slab registration
set BOLDbasename=\$subject\"_bld\*_\*_reorient.nii.gz\"
set fieldmap_correction=0         # 1 = fieldmap correction
$inithres
$inithresuthr 
set highres=($mpr)                    # MPRAGE 
set bold=($boldstr)               # all bold runs
set runid=($runtype)	

set bet_extract         = 1                             # 1 = brain extract (necessary when highres is T1 MPRAGE)
set bet_flags           = \"-g -.4\"
exit;


process_FC:

set fcbold=($boldstr)
set runid=($runtype)
@ skip = 0
set blur=0.735452
set oh=2
set ol=0
set bh=0.08
set bl=0.0
set ventreg=$ENV{'_HVD_CODE_DIR'}/masks/avg152T1_ventricles_MNI
set wmreg=$ENV{'_HVD_CODE_DIR'}/masks/avg152T1_WM_MNI
set wbreg=$ENV{'_HVD_CODE_DIR'}/masks/avg152T1_brain_MNI
set ppstr=reorient_skip_faln_mc_atl
set mvstr=reorient_skip_faln_mc
set G=1

";

`chmod 775 $paramsfile`;
close OUTPUT;

sub usage
{
  print "usage: fcparams.pl -id <session_id> -sdir /070523_4TT00250/scripts \n";
  print "options:\n";
  print "-id: specify session ID\n";
  print "-sdir: specify location to save results (default is './')\n";
  print "-TR: specify sampling rate\n";
  print "-skip: specify number of frames to skip\n";
  print "-mpr: specify t1 weighted mprage number\n";
  print "-epi: specify t1 weighted EPI number\n";
  print "-bold: specify resting bold run numbers\n";
  print "-T1target: specify T1 target image for normalizing MPRAGE\n";
  print "-T2target: specify T2 target image for normalizing BOLD\n";
  print "-SPMparams: specify location of SPM parameters file\n";
  exit;
}
