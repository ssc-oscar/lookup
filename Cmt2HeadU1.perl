#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl");
use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;
use Compress::LZF;

sub toHex { 
        return unpack "H*", $_[0]; 
} 

sub fromHex { 
        return pack "H*", $_[0]; 
} 

BEGIN { $SIG{'__WARN__'} = sub { if (0) { print STDERR $_[0]; } } };

my $split = 32;

my (%c2h, %c2cc);
my $ver = $ARGV[0];
my $pVer = $ARGV[1];

for my $s (0..($split-1)){
  tie %{$c2h{$s}}, "TokyoCabinet::HDB", "/fast/c2hFull$ver.$s.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT | TokyoCabinet::HDB::ONOLCK,
    16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
    or die "cant open /fast/c2hFull$ver.$s.tch\n";
}

for my $s (0..($split-1)){ 
  tie %{$c2cc{$s}}, "TokyoCabinet::HDB", "/fast/c2ccFull$ver.$s.tch", TokyoCabinet::HDB::OREADER | TokyoCabinet::HDB::ONOLCK,
      16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open /fast/c2ccFull$ver.$s.tch\n";
}
my $ncalc = 0;
my $nlook = 0;
my $mdepth = 0;

my %mapHeads;
open A, "zcat /data/basemaps/gz/hFull$pVer|";
while (<A>){ chop(); $mapHeads{$_} = "1"; };

open A, "zcat /data/basemaps/gz/cHasCcFull$ver.*|";
while (<A>){ 
  chop();
  my $ch = $_;
  next if ! defined $mapHeads{$ch};
  my $c = fromHex ($ch);
  my $s = (unpack "C", substr ($c, 0, 1)) % $split;
  if (defined $c2h{$s}{$c}){
    my $v = $c2h{$s}{$c};
    my %fix;
    my $ch = substr($v, 0, 20);
    my $d0 = unpack "w", substr($v, 20, length($v) - 20);
    $fix{$c}=$d0;
    #$d0 has to be zero for leafs
    my $d00 = $d0;
    my $sh = (unpack "C", substr ($ch, 0, 1)) % $split;
    while (defined $c2cc{$sh}{$ch}){
        # assign the right heads
	$fix{$ch}=$d0;
        my $vh = $c2cc{$sh}{$ch};
        $d0 += 1; #unpack "w", substr($vh, 20, length($vh) - 20);
        $ch = substr($vh, 0, 20);
        $sh = (unpack "C", substr ($ch, 0, 1)) % $split;
	#print "".(toHex ($c)).";".(toHex ($ch)).";$d0\n";
    } 
    $fix{$ch} = $d0;
    while (my ($c, $d) = each %fix){
      print "".(toHex ($c)).";".(toHex ($ch)).";".($d0-$d)."\n";
    }
  }
}
