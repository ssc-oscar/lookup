use strict;
use warnings;

my $pk = "";
my $tmp = "";
while (<STDIN>){
  chop ();
  my ($k, $v) = split(/;/, $_, -1);
  if ($pk ne "" && $k ne $pk){
    out ();
  }
  my $vb = pack "H*", $v;
  $pk = $k;
  $tmp .= $vb;
}
out();


sub out {
  my $kb = pack "H*", $pk;
  my $nv = pack "w", (length($tmp)/20);
  print $kb.$nv.$tmp;
  $tmp = "";
}
  

