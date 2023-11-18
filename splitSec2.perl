#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
# use IO::File;  
# use PerlIO::gzip;
use strict;
use warnings;


my $filename = $ARGV[0];
my $nseg = $ARGV[1];
my $frSeg = $ARGV[2];
my $piece = $ARGV[3];

my $fileno = 0;
my $line = 0;
my @fh;

for my $seg (0..($nseg-1)){
  my $fh;
  next if $seg % $frSeg != $piece;
  #open $fh1, '>:gzip', "${filename}$seg.gz";
  open $fh, "|gzip > ${filename}$seg.gz";
  $fh [$seg] = *$fh;
  #print "$seg;$fh[$seg]\n";
}
while (<STDIN>) {
  my $l = $_;
  my $ss = pack 'H*', substr ($_, 0, 2);
  my $seg = (unpack "C", $ss)%$nseg; 
  #print "1 - $l;$ss;$seg;$fh[$seg]\n";
  my $f = $fh[$seg];
  print $f $_;
}
