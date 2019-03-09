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
      for my $p (split(/\;/, safeDecomp ($c2p{$secc}{$c}))){
        $ps{$p}++;
      }
    }
  }
}
my $ncs2 = scalar (keys %cs2);
print STDERR "$p1;$ncs2;".(scalar(keys %ps))."\n";

while (<STDIN>){
  chop();
  my ($p, @x) = split(/\;/, $_, -1);
  next if !defined $ps{$p};

  my $sec = 0;
  $sec = sHash ($p, $split) if $split > 1;
  if (defined $p2c{$sec}{$p}){
    my %cs = ();
    list ($p2c{$sec}{$p}, \%cs);
    my @cs1 = keys %cs;
    my $ncs = $#cs1+1;
    my $shared = 0;
    for my $c (@cs1){
      $shared++ if defined $cs2{$c};
    }
    print "$p;$ncs;$p1;$ncs2;$shared\n";
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


