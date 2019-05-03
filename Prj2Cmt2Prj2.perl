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
  my $fname = "p2cFullN.$sec.tch";
  tie %{$p2c{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}


my %c2p;
for my $sec (0..($split-1)){
  my $fname = "c2pFullN.$sec.tch";
  tie %{$c2p{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,
         16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";
}

my $p1 = "";
$p1 = $ARGV[0] if defined $ARGV[0];

my $sec1 = 0;
my %ps = ();
my %cs2 = ();
$sec1 = sHash ($p1, $split) if $split > 1;
if (defined $p2c{$sec1}{$p1}){
  list ($p2c{$sec1}{$p1}, \%cs2);
  my @cs3 = keys %cs2;
  for my $c (@cs3){
    my $secc = segB ($c, $split);
    if (defined $c2p{$secc}{$c}){
      list1 ($c2p{$secc}{$c}, \%ps);
    }
  }
}
my $nps = scalar (keys %ps);
print "$p1;$nps\n";
my %ps1;
my %cs = ();
for my $p (keys %ps){
  my $sec = 0;
  $sec = sHash ($p, $split) if $split > 1;
  if (defined $p2c{$sec}{$p}){
    list ($p2c{$sec}{$p}, \%cs);
  }
}
for my $c (keys %cs){
  my $secc = segB ($c, $split);
  if (defined $c2p{$secc}{$c}){
    for my $p (split(/\;/, safeDecomp ($c2p{$secc}{$c}))){
      $ps1{$p}++ if !defined $ps{$p};
    }
  }
}
my $nps1 = scalar (keys %ps1);
print "$nps1\n";

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


