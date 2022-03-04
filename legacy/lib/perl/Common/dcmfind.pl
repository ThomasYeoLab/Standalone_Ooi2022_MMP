#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
use Cwd;
use Cwd 'abs_path';
use File::Find;

my %options;
my $sid='';
my @dirs;
my $dirname;


if (@ARGV < 1){usage();}

GetOptions(\%options,"id=s"); 

if ($options{id}){$sid = $options{id};}
chomp($sid);


chdir($sid) or die("$!");
# Get an array of all subdirectories
my $search = shift || '.';
find sub { push @dirs, $File::Find::name if -d }, $search;

for my $dir ( @dirs ) {


opendir my $dh, $dir or do {
warn "Cannot open '$dir' $!";
next;
};

while ( my $file = readdir $dh ){

if (grep(/.dcm/,$file) eq 1) {
$dirname = $dir;
print $dirname;
exit;  
}

}



}


sub usage
{
  print "usage: dcmfind.pl -id 070612_4TT00265\n";
  print "options:\n";
  print "-id: specify session ID\n";
  exit;
} 
