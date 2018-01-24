#!/bin/perl -I /home/audris/lib64/perl5

use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;

sub toNum { 
        return unpack "L*", $_[0]; 
} 

sub fromNum { 
        return pack "L*", $_[0]; 
} 

my %a2f;
my %f2a;
my %fstat;

tie %a2f, "TokyoCabinet::HDB", "A2F.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open A2F.tch\n";
#tie %f2a, "TokyoCabinet::HDB", "F2A.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
#        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
#     or die "cant open F2A.tch\n";
tie %fstat, "TokyoCabinet::HDB", "F2NC.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open F2NC.tch\n";

while (<STDIN>){
  chop();
  my $na = $_ + 0;
  my $n = fromNum ($na);
  my $fs = getFs ($a2f{$n});
  my %d = ();
  for my $f (keys %{$fs}){
    my $fn = 1.0/toNum($fs->{$f});
    #print "$na;".(toNum($f)).";$fn\n";
    #print "$na".(toNum($f))."\n";
    my $as = getAs ($f2a{$f});
    for my $au (keys %{$as}){
     $d{$au} += $fn;
    }
  }
  for my $au (sort { $d{$b} <=> $d{$a} } keys %d){
    print "$na;".(toNum($au)).";$d{$au}\n";
  }
}

sub getFs {
  my $v = $_[0];
  my $ns = length($v)/4;
  my %fs = ();
  for my $i (0..($ns-1)){
    my $a = substr ($v, 4*$i, 4);
    $fs{$a} = $fstat{$a};
  }
  return \%fs;
}

sub getAs {
  my $v = $_[0];
  my $ns = length($v)/4;
  my %as = ();
  for my $i (0..($ns-1)){
    my $a = substr ($v, 4*$i, 4);
    $as{$a}++;
  }
  return \%as;
}

