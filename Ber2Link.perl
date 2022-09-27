#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use warnings;
use strict;

my $pre = "";
my $line = 0;
while (! eof (STDIN) ){
  my $buf;
  read (STDIN,$buf,1000);
  $buf = $pre.$buf;
  my $tot = length($buf);
  while ($tot > 30){
    my ($a, $b) = unpack "w2", $buf;
    $buf = substr ($buf, length (pack "w", $a) + length (pack "w", $b));
    $tot = length($buf);
    print "$a $b\n";
    $line ++;
  }
  $pre = $buf;
}
if (length ($pre) > 0){
  my @ns = unpack "w*", $pre;
  for my $i (0..int(($#ns-1)/2)){
    print $ns[$i*2]." ".$ns[$i*2+1]."\n";
  }
}
