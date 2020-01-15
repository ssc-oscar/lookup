#!/usr/bin/perl

use warnings;
use strict;
use File::Temp qw/ :POSIX /;


my $t0 = time();
print STDERR "starting at $t0\n";
open A, "|gzip>$ARGV[0].names";
open B, "|gzip>$ARGV[0].versions";
my (%f2num);
my $n = 0;
my $i = 0;

while(<STDIN>){
  chop();
  my ($id, @vs) = split(/\;/, $_, -1);
  my @vs1 = (); 
  for my $v1 (@vs){
    push @vs1, $v1;
    if (!defined $f2num{$v1}){
      $f2num{$v1} = $i+0;
      print A "$v1\n";
      $i++;
    }
  }
  my $v0 = shift @vs1;
  for my $v1 (@vs1){
    print B "$f2num{$v0} $f2num{$v1}\n";
  } 
  $n ++;
  if (!($n%100000000)) { print STDERR "$n lines and $i nodes in $ARGV[0] done\n";}
}
print B "".($i-1)." ".($i-1)."\n";#ensure a complete list of vertices
my $t1 = time();
print STDERR "finished at $t1 over ".($t1-$t0)."\n"; 
