#!/usr/bin/perl
use strict;
use warnings;

my $off = (pop @ARGV)-1;


my %match;
for my $str (@ARGV){
  open A, "gunzip -c $str|";
  while(<A>){
    chop();
    my @x = split(/;/);
    next if $x[0] eq "";
    $match{$x[0]}++;
  }
}

while(<STDIN>){
  chop();
  my @x = split(/\;/, $_, -1);
  next if !defined $x[$off] || $x[$off] eq "";
  my $cmp = $x[$off];
  if (!defined $match{$cmp}){
    print "$_\n";
  }
}
