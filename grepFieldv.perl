#!/usr/bin/perl
use strict;
use warnings;

my $off = (pop @ARGV)-1;


my %match;
for my $str (@ARGV){
  open A, "gunzip -c $str|";
  while(<A>){
    chop();
    next if $_ eq "";
    $match{$_}++;
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
