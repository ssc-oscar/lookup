#!/usr/bin/perl -I /home/audris/lib/perl5 -I /home/audris/lookup
use IO::File;  
use strict;
use warnings;
use cmt;

my $filename = $ARGV[0];
my $nseg = $ARGV[1];


my $fileno = 0;
my $line = 0;
my @fh;
for my $seg (0..($nseg-1)){
  my $fh;
  open $fh, "|gzip > ${filename}$seg.gz";
  $fh [$seg] = *$fh;
}
while (<STDIN>) {
  my $l = $_;
  #my $seg = (unpack "C", substr ($l, 0, 1))%$nseg;
  my $seg = sHash ($l, $nseg);
  my $f = $fh[$seg]; 
  print $f $_; 
}
