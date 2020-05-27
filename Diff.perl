#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
use strict;
use warnings;
sub ltrim { my $s = shift; $s =~ s/^\s+//;       return $s }

open A, "zcat $ARGV[0]|";
open B, "zcat $ARGV[1]|";

my $pa = "";
my $pb = "";
my %v = ();
my %v1 = ();
my %tmpa = ();
my %tmpb = ();

my $vala = readPieceA ();
my $valb = readPieceB ();
my $la = 0;
my $lb = 0;
while ($vala){
  if ($pa eq $pb){
    for my $k (keys %v){
      print "$pa;$k\n" if !defined $v1{$k};
    }
    %v = ();
    for my $k (keys %tmpa){ $v{$tmpa{$k}}++; $pa = $k; };
    %v1 = ();
    for my $k (keys %tmpb){ $v1{$tmpb{$k}}++; $pb = $k; };
    %tmpb = ();
    %tmpa = ();
    $vala = readPieceA ();
    $valb = readPieceB ();
  }else{
    my $pa0 =  ltrim ($pa); 
    my $pb0 =  ltrim ($pb); 
    if (($pa0 cmp $pb0) < 0){
      #print "$la:$lb: whole:$pa:$pb:\n";
      for my $k (keys %v){
        print "$pa;$k\n";
      }
      %v = ();
      for my $k (keys %tmpa){ $v{$tmpa{$k}}++; $pa = $k; };
      %tmpa = ();
      $vala = readPieceA ();
    }else{
      #bad sort, 
      for my $k (keys %v){
        print "$pa;$k\n";
      }
      %v = ();for my $k (keys %tmpa){ $v{$tmpa{$k}}++; $pa = $k; };%tmpa = ();
      $vala = readPieceA ();
      #print STDERR "cant happen :$la:$lb:\n";
      #exit ();
    }
  }
}
  
sub readPieceA {
  while (<A>){
    $la++;
    chop();
    $_ =~ m/^([^;]*);(.*)/;
    my ($a, $b) = ($1, $2);
    if ($pa ne "" && $a ne $pa){
      $tmpa{$a} = $b;
      return 1;
    }
    $v{$b}++;
    $pa = $a;
  }
  return 0;
}


sub readPieceB {
  while (<B>){
    $lb++;
    chop();
    $_ =~ m/^([^;]*);(.*)/;
    my ($a, $b) = ($1, $2);
    if ($pb ne "" && $a ne $pb){
      $tmpb{$a} = $b;
      return 1;
    }
    $v1{$b}++;
    $pb = $a;
  }
  return 0;
}

