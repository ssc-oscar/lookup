use strict;
use warnings;

my $f = $ARGV[0];
my $vlen = 20;
$vlen = $ARGV[1] if defined $ARGV[1];

open A, "|gzip > $f.idx";
open B, "> $f.bin";

my $pk = "";
my $ntot = 0;
my $nc = 0;
while (<STDIN>){
  chop ();
  my ($k, $v) = split(/;/, $_, -1);
  if ($pk ne "" && $k ne $pk){
    out ();
  }
  my $vb = pack "H*", $v;
  $pk = $k;
  print B $vb;
  $nc ++;
}
out();


sub out {
  my $kb = pack "H*", $pk;
  my $nt = pack "w", $ntot;
  my $nv = pack "w", $nc;
  $ntot += $nc;
  print A $kb.$nt.$nv;
  $nc = 1;
}
  

