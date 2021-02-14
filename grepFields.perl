#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use strict;
use warnings;


my $lines = 0;
if ($ARGV[0] eq "-n"){
  $lines = 1;
  shift @ARGV;
}

my $str = $ARGV[0];
my $off = 0;
$off = $ARGV[1]-1 if defined $ARGV[1];

my %match;
open A, "gunzip -c $str|";
while(<A>){
  s/\n$//;
  next if $_ eq "";
  my $str = $_;
  my @x = split(/\./, $str);
  $match{$#x}{$_}++;
}

my $line = 0;
while(<STDIN>){
  chop();
  $line ++;
  my @x = split(/\;/, $_, -1);
  for my $o ($off..$#x){
    next if !defined $x[$o] || $x[$o] eq "";
    my @x = split(/\./, $x[$o]);
    my $s = $x[0];
    next if !defined $s || $s eq "";
    if (defined $match{0}{$s}){
      if ($lines){ print "$line:$_\n"; }else {print "$_\n";};
      #print STDERR "$o;$s\n";
      last;
    }
    for my $i (1..$#x){
      $s .= ".$x[$i]"; 
      if (defined $match{$i}{$s}){
        if ($lines){
          print "$line:$_\n";
        }else{
          print "$_\n";
        }
        last;
      }
    }
  }
}

