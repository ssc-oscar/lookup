#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

use warnings;
use strict;
use File::Temp qw/ :POSIX /;
use woc;
my $ver = $ARGV[0];
my %fix;
open A, "eMap$ver.fix";
while (<A>){
  chop ();
  my ($a, $b) = split (/\;/);
  $fix{$a} = $b;
}

my (%badE, %badU);
open BE, "bad$ver.e";
while (<BE>){
  chop();
  my ($e, $n) = split(/;/, $_);
  $e = lc($e);
  my $u = (split(/@/, $e))[0];
  $badE{$e} += $n;
  $badU{$u} += $n if defined $u;
}
$badE{""}=1000;
$badU{""}=1000;
my %badN;
my %badFN;
my %badLN;
open BE, "bad$ver.fl";
while (<BE>){
  chop();
  my ($fn, $ln, $c) = split(/;/, $_);
  my $n = "";
  if ($fn ne "" && $ln ne ""){
    $n = "$fn $ln";
    $badN{lc($n)} += $c;
    $badFN{lc($fn)} += $c;
    $badFN{lc($ln)} += $c;
    $badLN{lc($ln)} += $c;
    $badLN{lc($fn)} += $c;
  }else{
    if ($fn ne ""){
      $badFN{lc($fn)} += $c;
      $badLN{lc($fn)} += $c;
    }
    if ($ln ne ""){
      $badFN{lc($ln)} += $c;
      $badLN{lc($ln)} += $c;
    }
  }
}
$badLN{""}=1000;
$badFN{""}=1000;
my %badGH;
open BE, "bad$ver.gh";
while (<BE>){
  chop();
  my ($gh, $n) = split(/;/, $_);
  $badGH{lc($gh)} += $n;
}
$badGH{""}=1000;

open A, "zcat Cmt$ver.split|";
my %bin;
while(<A>){
  chop();
  my ($id, $fn, $ln, $u, $h, $e, $gh) = split (/;/, $_);
  $id =~ s/\r/ /g;
  my $n = "";
  if ($fn ne "" && $ln ne ""){
    $n = "$fn $ln";
  }
  $bin{fn}{$fn}{$id}++ if $fn ne "" && defined $badFN{$fn} && $badFN{$fn} < 100;
  $bin{ln}{$ln}{$id}++ if $ln ne "" && defined $badLN{$ln} && $badLN{$ln} < 100;
  $bin{n}{$n}{$id}++ if $n ne "" && defined $badN{$n} && $badN{$n} < 100;
  $bin{e}{$e}{$id}++ if defined $badE{$e} && $badE{$e} < 100;
  $bin{gh}{$gh}{$id}++ if defined $badGH{$gh} && $badGH{$gh} < 100;
  $bin{u}{$u}{$id}++ if defined $badU{$u} && $badU{$u} < 100;
}
for my $t ("fn", "ln", "n", "e", "gh", "u"){
  my @kall = keys %{$bin{$t}};
  print STDERR "$t;$#kall\n";
  my @ks = sort { scalar (keys %{$bin{$t}{$a}}) <=> scalar (keys %{$bin{$t}{$b}}) }  (@kall);
  for my $a (@ks){
    my @vs = keys %{$bin{$t}{$a}};
    my $nn = scalar (@vs);
    print "$t;$a;".(join ";",@vs)."\n" if $nn > 1 && $nn < 30;
  }
}
