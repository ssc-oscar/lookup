#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use strict;
use warnings;


my $str = $ARGV[0];
my $off = 0;
my $off1 = 1;
$off = $ARGV[1]-1 if defined $ARGV[1];
$off1 = $ARGV[2]-1 if defined $ARGV[2];

my %match;
open A, "gunzip -c $str|";
while(<A>){
        chop();
        next if $_ eq "";
        my ($a, $b) = split(/;/);
        $match{$a}=$b;
}

my $line = 0;
while(<STDIN>){
  chop();
  $line ++;
  my @x = split(/\;/, $_, -1);
  if (defined $match{$x[$off]}){
    $x[$off1] = $match{$x[$off]};
  }
  print "".(join ';', @x)."\n";
}

