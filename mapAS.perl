use strict;
use warnings;

my $map = "a2AFullS.s";
$map = $ARGV[1] if defined $ARGV[1];
my %p2P;
my %bad;
open A, "zcat $map|";
while (<A>){
  chop();
  my ($f, $t, $b, $b1) = split(/;/);
  if ($b > 0 || $b1 > 0){
    $bad{$f}++;
  }else{
    $p2P{$f} = $t;
  }
}

my @cols = ($ARGV[0]+0);
for my $i (2..$#ARGV){
  push @cols, $ARGV[$i];
}
  
while(<STDIN>){
  chop();
  my @x=split(/;/);
  my $pr = 0;
  my @extra = ();
  for my $col (@cols){
    my $v = "";
    if (defined $x[$col] && defined $p2P{$x[$col]}){
      $v .= ";$p2P{$x[$col]}";
    }else{
      $v .= ";";
    }
    if (defined $x[$col] && defined $bad{$x[$col]}){ 
      $v .= ";1";
    }else{
      $v .= ";";
    }
    $x[$col] = $x[$col].$v;
  }
  print "".(join ';', @x)."\n";
}
