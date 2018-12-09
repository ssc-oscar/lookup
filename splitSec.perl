#!/usr/bin/perl
# use IO::File;  
# use PerlIO::gzip;
use strict;
use warnings;


my $filename = $ARGV[0];
my $nseg = $ARGV[1];
my $show = 0;
$show = $ARGV[2] if defined $ARGV[2];

my $fileno = 0;
my $line = 0;
my @fh;

if (!$show){
  for my $seg (0..($nseg-1)){
    my $fh;
    #open $fh, '>:gzip', "${filename}$seg.gz";
    open $fh, "|gzip > ${filename}$seg.gz";
    $fh [$seg] = *$fh;
  }
}
while (<STDIN>) {
  my $l = $_;
  my $ss = pack 'H*', substr ($_, 0, 2);
  my $seg = (unpack "C", $ss)%$nseg; 
  if (!$show){
    my $f = $fh[$seg]; 
    print $f $_;
  }else{
    print "$seg;$_";
  } 
}
