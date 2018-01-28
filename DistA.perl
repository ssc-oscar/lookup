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

tie %a2f, "TokyoCabinet::HDB", "/fast1/A2F.tch", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open /fast1/A2F.tch\n";
tie %f2a, "TokyoCabinet::HDB", "/fast1/F2A.tch", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open /fast1/F2A.tch\n";

while (<STDIN>){
  chop();
  my $na = $_ + 0;
  print STDERR "doing $na\n";
  my $n = fromNum ($na);
  my $fs = getFs ($a2f{$n});
  my %d = ();
  for my $f (keys %{$fs}){
    #what about the fraction of all commits n made of f?
    my $as = getAs ($f2a{$f});
    my @aus = keys %{$as};
    my $w = 1.0/($#aus+1);
    for my $au (@aus){
      $d{$au} += $w;
    }
  }
  my $nn = 0;
  for my $au (sort { $d{$b} <=> $d{$a} } keys %d){
    print "$na;".(toNum($au)).";$d{$au}\n";
    $nn++;
    last if $nn > 200;
  }
}

sub getFs {
  my $v = $_[0];
  my $ns = length($v)/4;
  print STDERR "$ns files\n";
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
  #print STDERR "$ns authors\n";
  my %as = ();
  for my $i (0..($ns-1)){
    my $a = substr ($v, 4*$i, 4);
    $as{$a}++;
  }
  return \%as;
}

