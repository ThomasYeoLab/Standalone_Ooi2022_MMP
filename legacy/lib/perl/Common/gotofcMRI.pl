#!/usr/bin/perl
# gotofcMRI.pl

use strict;
use Getopt::Long;
my $sid;
my $params;
my %options;
my $bool;
my $pattern;

if (@ARGV < 1){usage();}

GetOptions(\%options, "id=s", "sdir=s");

if ($options{id}){ $sid = $options{id};}

if ($options{sdir}){

opendir DH, "$options{sdir}" or die "Error: directory '$options{sdir}' does not exist in the file system.\n";
$bool = 0;
$params = "$sid.params";
while ($_ = readdir(DH)){

if ($_ eq "$params"){$bool = 1; last;}

}
if ($bool == 1) {print "FOUND: $params\n";}
if ($bool == 0) {print "Cannot read '$sid.params' in directory '$options{sdir}/scripts': change permission settings.\n"; exit;}
closedir DH;
}

chdir("$options{sdir}");


  my $old = "$params";
  my $new = "$params.new";
  my $bak = "$params.bak";
  $pattern = "\#goto process_FC"; #pattern to search for
    open(OLD, "< $old")         or die "can't open $old: $!";
    open(NEW, "> $new")         or die "can't open $new: $!";

    # Correct typos, preserving case
    while (<OLD>) {
        s/\b(p)earl\b/${1}erl/i;
	if (/$pattern/){
	s/#goto process_FC/goto process_FC/;    #uncomment goto process_FC
	}
        (print NEW $_)          or die "can't write to $new: $!";
    }

    close(OLD)                  or die "can't close $old: $!";
    close(NEW)                  or die "can't close $new: $!";
    `chmod 775 $new`;
    rename($old, $bak)          or die "can't rename $old to $bak: $!";
    rename($new, $old)          or die "can't rename $new to $old: $!";


print `pwd`;




sub usage
{
  print "usage: gotofcMRI.pl -id <session_id> -sdir /070523_4TT00250/scripts \n";
  print "options:\n";
  print "-id: specify session ID\n";
  print "-sdir: specify location where parameters file is located\n";
  
  exit;
}
