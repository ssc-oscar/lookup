#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use strict;
use warnings;

my $off = (pop @ARGV)-1;

my $lines = 0;
if ($ARGV[0] eq "-n"){
  $lines = 1;
  shift @ARGV;
}
my %match;
for my $str (@ARGV){
  open A, "gunzip -c $str|";
  while(<A>){
    s/\n$//;
   #chop();
    next if $_ eq "";
    $match{$_}++;
  }
}

my $line = 0;
while(<STDIN>){
  chop();
  $line ++;
  my @x = split(/\;/, $_, -1);
  next if !defined $x[$off] || $x[$off] eq "";
  if (defined $match{$x[$off]}){
    if ($lines){
      print "$line:$_\n";
    }else{
      print "$_\n";
    }
  }
}

