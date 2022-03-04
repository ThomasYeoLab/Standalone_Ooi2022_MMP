#!/usr/bin/perl

# $Id: wbc4to2interp.pl,v 1.0 2009/08/11 17:17:02 mtt24 Exp $

use strict;
use Getopt::Long;
use File::Basename;




if (@ARGV < 1){usage();}


my %options;
my $sid;
my $img; 
my @imglist;
my @wbcdat;
my $bcfile1 = "";
my $bcfile2 = "";
my $bcfile3 = "";
my $savedir = "./";

GetOptions(\%options, "imglist=s", "img=s", "save=s");

if ($options{img}){
$_ = $options{img};  
s/,/ /g; 
$img = $_;
@imglist = split / /, $img;
}

if ($options{imglist}){
open(FILE,$options{imglist}) || die "Error: cannot open file '$options{roilist}'";


if ($options{save}){
$savedir = $options{save};
}

while(<FILE>){
#print $_; # echo line read
  my $line = $_;
  chomp ($line);
  push @imglist, $line;
}
close(FILE);
}



for (my $i = 0; $i <= $#imglist; $i++){
if (-e $imglist[$i] ) {print "FOUND: $imglist[$i]\n";}
else {print "Error: could not find '$imglist[$i]'\n"; exit;}
if (! -r $imglist[$i]) {print "Error: could not read $imglist[$i], change permission settings.\n";}


}
 
#convert 4x4x4mm data to 2x2x2mm data using nearest neighbor method

#generate init file
my $init = "init.mat";
print "Writing: $init\n";
open(OUTPUT, '>', $init) or die "Could not open file $init for writing: %!\n";
printf OUTPUT "1 0 0 0\n";
printf OUTPUT "0 1 0 0\n";
printf OUTPUT "0 0 1 0\n";
printf OUTPUT "0 0 0 1\n";
close OUTPUT;


`fslcreatehd 91 109 91 1 2 2 2 1 0 0 0 16 resampled_tmp.nii.gz`;

for (my $i = 0; $i <= $#imglist; $i++){
my $upsampfile = fileparse($imglist[$i], qr/\.nii\.gz/);
print "Writing: ${upsampfile}_222.nii.gz\n";
`flirt -in $imglist[$i] -applyxfm -init ./init.mat -out ${savedir}/${upsampfile}_222 -paddingsize 0.0 -interp nearestneighbour -ref resampled_tmp`
}

`rm init.mat`;
`rm resampled_tmp.nii.gz`;




sub usage
{
use vars qw
	(
	$VERSION
	    );

  $VERSION = q$\$Id: wbc4to2interp.pl,v 1.0 2009/08/11 17:17:02 mtt24 Exp $;
  print "$VERSION\n";
  print "Example usage:\n";
  print "wbc4to2interp.pl -img <.nii.gz>\n";
  print "wbc4to2interp.pl -imglist <.txt> -save <path>\n";
  exit;

}
