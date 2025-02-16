use strict;
use warnings;

my $f = $ARGV[0];
my $klen = 4;
my $vlen = 20;
$klen = $ARGV[1] if defined $ARGV[1];
$vlen = $ARGV[2] if defined $ARGV[2];
my $nkl = $klen*2;
my $nvl = $vlen*2;

open A, "|gzip > $f.idx";
open B, "> $f.bin";
binmode B;
binmode A;

my $pk = "";
my $ntot = 0;
my $nc = 0;
while (<STDIN>){
  chop ();
  my ($k, $v) = split(/;/, $_, -1);
  if ($pk ne "" && $k ne $pk){
    out ();
  }
  if ($_ =~ m/^[0-9a-f]{$nkl};[0-9a-f]{$nvl}$/){
    my $vb = pack "H*", $v;
    $pk = $k;
    print B $vb;
  }else{
    die "wrong length $klen;$vlen for $k;$v\n";
  }
  $pk = $k;
  $nc ++;
}
out();
close B;
close A;

sub out {
  my $kb = pack "H*", $pk;
  my $nt = pack "w", $ntot;
  my $nv = pack "w", $nc;
  $ntot += $nc;
  print A $kb.$nt.$nv;
  $nc = 0;
}
  

