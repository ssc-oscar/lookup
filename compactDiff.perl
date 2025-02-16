use strict;
use warnings;

while (<STDIN>){
  chop();
  my @x = split (/\;/, $_, -1);
  if (length ($x[3]) > 40){
    my @y = split(/ /, $x[3], -1);
    if ($#y > 8){
      $x[3] = "$y[0] $y[1] $y[2] $y[3] $y[4] $y[5] $y[6] $y[7] $y[8] ...";
    }
  }
  print "".(join ';', @x)."\n";
}
