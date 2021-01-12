use strict;
use warnings;

use utf8;
no utf8;

# grembo <grembo@FreeBSD.org>;1053;729;835;4;1390310598;1598550060;2;Rust=1;Python=39;Perl=4;PHP=14;other=578;C/C++=93
my %a2A;
open B, "zcat $ARGV[0]|";
while (<B>){
  chop ();
  my ($a, $A) = split (/;/);
  $a2A{$a} = $A;
}
my %d;
while (<STDIN>){
  chop ();
  my ($a, @stats) = split (/;/, $_, -1);
  next if !defined $a2A{$a};
  my $A = $a2A{$a};
  $d{$A}{c}++;
  for my $i (0..$#stats){
    $d{$A}{$i} += $stats[$i] if $stats[$i] ne "" && ($i < 4 || $i == 6);
    if ($i == 4 || $i == 5){
      if ($stats[$i] ne "" && $stats[$i] > 0){
        $d{$A}{$i} = ((!defined $d{$A}{$i} || $stats[$i] < $d{$A}{$i}) ? $stats[$i] : $d{$A}{$i}) if $i == 4;   
        $d{$A}{$i} = ((!defined $d{$A}{$i} || $stats[$i] > $d{$A}{$i}) ? $stats[$i] : $d{$A}{$i}) if $i == 5;
      }
    }
    if ($i > 6){
      my ($k, $v) = split (/=/, $stats[$i]);
      $d{$A}{e}{$k}+=$v;
    }
  }
}
for my $a (keys %d){
  print "$a;$d{$a}{c};$d{$a}{0};$d{$a}{1};$d{$a}{2};$d{$a}{3};$d{$a}{4};$d{$a}{5};$d{$a}{6}";
  for my $ee (keys %{$d{$a}{e}}){
    print ";$ee=$d{$a}{e}{$ee}";
  }
  print "\n";
}
