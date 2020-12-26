use strict;
use warnings;

my $map = "p2P.s";
$map = $ARGV[1] if defined $ARGV[1];
my %p2P;
open A, "zcat $map|";
while (<A>){
  chop();
  my ($f, $t) = split(/;/);
  $p2P{$f} = $t if $f ne $t; # don't store identity
}

my $col = $ARGV[0]+0;
while(<STDIN>){
  chop();
  my @x=split(/;/);
  print "$_;$p2P{$x[$col]}\n" if $x[1] eq "AgnisLV_yii2-mpdf";
  $x[$col] = $p2P{$x[$col]} if defined $x[$col] && defined $p2P{$x[$col]};
  print "".(join ';', @x)."\n";
}
