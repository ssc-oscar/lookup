#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use warnings;
use strict;
use File::Temp qw/ :POSIX /;


my $t0 = time();
open A, "|gzip>$ARGV[0].names";
open B, "|gzip>$ARGV[0].versions";
my (%f2num);
my $n = 0;
my $i = 0;
my %tmp;
my $pa = "";
while(<STDIN>){
  chop();
  my ($a, $b) = split(/\;/, $_, -1);
  if ($pa ne "" && $pa ne $a){
    out ();
  }
  $tmp{$b}++;
  $pa = $a;
}
out();

sub out {
  my @vs = keys %tmp;
  return if $#vs < 1;
  if (!defined $f2num{$pa}){
    $f2num{$pa} = $i+0;
    print A "$pa\n";
    $i++;
  }
  for my $v (@vs){
    if (!defined $f2num{$v}){
      $f2num{$v} = $i+0;
      print A "$v\n";
      $i++;
    }
    print B "$f2num{$pa} $f2num{$v}\n";
  }
}
