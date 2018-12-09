#!/usr/bin/perl -I /home/audris/lib64/perl5 -I /home/audris/lookup
use IO::File;  
use strict;
use warnings;
use cmt;

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
    open $fh, "|gzip > ${filename}$seg.gz";
    $fh [$seg] = *$fh;
  }
}

while (<STDIN>) {
  chop ();
  my ($l, @x) = split (/\;/, $_, -1);
  #my $seg = (unpack "C", substr ($l, 0, 1))%$nseg;
  my $seg = sHash ($l, $nseg);
  if (!$show){
    my $f = $fh[$seg]; 
    print $f "$_\n";
  }else{
    print "$seg;$_\n"; 
  }
}
