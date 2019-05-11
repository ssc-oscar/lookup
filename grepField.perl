#!/usr/bin/perl

use strict;
use warnings;

my $str = $ARGV[0];
my $off = 0;
$off = $ARGV[1]-1 if defined $ARGV[1];

my %match;
open A, "gunzip -c $str|";
while(<A>){
        chop();
        next if $_ eq "";
        $match{$_}++;
}

while(<STDIN>){
  chop();
  my @x = split(/\;/, $_, -1);
  next if !defined $x[$off] || $x[$off] eq "";
  if (defined $match{$x[$off]}){
    print "$_\n";
  }
}

