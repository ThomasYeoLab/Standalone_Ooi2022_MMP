#!/usr/bin/perl

# $Id: zscore.pl,v 1.2 2008/08/11 21:17:02 mtt24 Exp $

use strict;
use Getopt::Long;
use File::Basename;

if (@ARGV < 1){usage();}


my %options;
my $input;
my $mean;
my $sd;
my $subimg;
my $file;
my $dir;
my $ext;


  

GetOptions(\%options, "i=s");

if ($options{i}){
$input = $options{i};
}

($file,$dir,$ext) = fileparse($input,  qr/\.\D.*/);
$subimg = "subimg.nii.gz";
$mean = `fslstats $input -M`;
chomp($mean);
$sd = `fslstats $input -S`;
chomp($sd);
`fslmaths $input -sub $mean $subimg`;
`fslmaths $subimg -div $sd ${file}_Z.nii.gz`;
`rm $subimg`;


exit 1;

sub usage
{
use vars qw
	(
	$VERSION
	    );

  $VERSION = q$\$Id: zscore.pl,v 1.0 2008/09/11 21:17:02 mtt24 Exp $;
  print "zscore.pl -i <.nii.gz>\n";
  print "$VERSION\n";
  exit;

}
