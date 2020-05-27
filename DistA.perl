#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl");

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
my %i2a;
my %a2i;

my $unmap = 0;
$unmap = $ARGV[0] if ($ARGV[0]);
if ($unmap){
  open A, "gunzip -c Auth2FID.idxa|";
  while (<A>){
    chop();
    my ($i, $a) = split (/\;/);
    $i2a{$i} = $a;
    $a2i{$a} = $i;
  }
}

tie %a2f, "TokyoCabinet::HDB", "/fast1/A2F.tch", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open /fast1/A2F.tch\n";
tie %f2a, "TokyoCabinet::HDB", "/fast1/F2A.tch", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open /fast1/F2A.tch\n";


while (<STDIN>){
  chop();
  my $na = $_;
  my $na0 = $na;
  if ($unmap){
    $na = $a2i{$na};
  }else{
    $na = $na0 + 0;
  }
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
    my $a = toNum($au);
    $a = $i2a{$a} if ($unmap);
    print "$na0;$a;$d{$au}\n";
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

