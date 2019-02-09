#!/usr/bin/perl -I /home/audris/lookup -I /home/audris/lib64/perl5 -I /home/audris/lib/x86_64-linux-gnu/perl
use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;
use cmt;


my $split = 32;

my %p2c;
for my $sec (0..($split-1)){
  my $fname = "p2cFullM.$sec.tch";
  tie %{$p2c{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}


my %c2p;
for my $sec (0..($split-1)){
  my $fname = "c2pFullM.$sec.tch";
  tie %{$c2p{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,
         16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}



while (<STDIN>){
  chop();
  my ($p) = split(/\;/, $_, -1);
  #my $sec = (unpack "C", substr ($p, 0, 1))%$split;
  my $sec = 0;
  $sec = sHash ($p, $split) if $split > 1;
  #print "$sec;$p\n";
  if (defined $p2c{$sec}{$p}){
    my %cs = ();
    list ($p2c{$sec}{$p}, \%cs);
    my %ps = ();
    my @cs1 = keys %cs;
    my $ncs = $#cs1+1;
    for my $c (@cs1){
      my $sc = (unpack "C", substr ($c, 0, 1))%32;
      list1 ($c2p{$sc}{$c}, \%ps);
    }
    my @ps1 = keys %ps; 
    my $np = $#ps1+1;
    #print "$p;$np";
    for my $p0 (@ps1) { print "$p;$ncs;$p0;$ps{$p0}\n";}
    #print "\n";
  }else{
    print STDERR "no $p in $sec\n";
  }
  
}


for my $sec (0..($split-1)){
  untie %{$p2c{$sec}};
  untie %{$c2p{$sec}};
}


sub list {
  my ($v, $cs) = @_;
  my $ns = length($v)/20;
  for my $i (0..($ns-1)){
    my $c = substr ($v, 20*$i, 20);
    $cs ->{$c}++;
  }
}

sub list1 {
  my ($v, $p) = @_;
  my $v1 = safeDecomp ($v);
  my @ps = split(/\;/, $v1, -1);
  for my $p0 (@ps) { $p ->{$p0}++; };
}


