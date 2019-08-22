#!/usr/bin/perl -I /home/audris/lib64/perl5 -I /home/audris/lib/x86_64-linux-gnu/perl
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
my $sec = $ARGV[0];
my $ver = $ARGV[1];
my $pVer = $ARGV[2];

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
my $mdepth x= 0;


#first get heads for the previous version
#for i in {0..31}; do time ./lst.perl /data/basemaps/c2hFull$pVer.0.tch h r | cut -d\; -f4 | uniq; done | lsort 50G -u | gzip > /data/basemaps/gz/hFull$pVer

my %mapHeads;
open A, "zcat /data/basemaps/gz/hFull$pVer|";
while (<A>){ chop(); $mapHeads{$_} = "1"; };

#now get current no-child commits
#for i in {0..31..4}; do time ./lst.perl /data/basemaps/c2ccFull$ver.$i.tch h h | cut -d\; -f1 | gzip > /data/basemaps/gz/cHasCcFull$ver.$i; done &

my %hasC;
open A, "zcat /data/basemaps/gz/cHasCcFull$ver.$i|";
while (<A>){ chop();
  chop();
  my $ch = $_;
  $hasC{$ch}++;
  if (defined $mapHeads{$ch}){
    my $c = fromHex ($ch);
    my $s = (unpack "C", substr ($c, 0, 1)) % $split;
    if (!defined $c2h{$s}{$c}){
      if (defined $c2cc{$s}{$c}){
        my $v = substr($c2cc{$s}{$c}, 0, 20);
        my ($ch, $h, $d) = findHead ($ch, $v, 1);
        my $dp = pack 'w', $d;
        $c2h{$s}{$c} = $h.$dp;
        $mapHeads{$c} = $h.$dp;        
      }
    } 
  }
};


# now fix all instances of problems
for my $s (0..($split-1)){
  while (my ($c, $h) = each %{$c2h{$s}}){
    my $hh = substr($h, 0, 20);
    if (defined $mapHeads{$hh}){
      my $d0 = unpack "w", substr($h, 20, length($h) - 20);
      my $hr = substr($mapHeads{$hh}, 0, 20);
      my $dAdd = unpack "w", substr($mapHeads{$hh}, 20, length($mapHeads{$hh}) - 20);
      my $dp = pack 'w', $d0+$dAdd;
      $c2h{$s}{$c} = $hr.$dp;     
    }else{
      #print "F:$ch;$ch;$ch;0\n;"
    }
  }
}
for my $s (0..($split-1)){ 
  untie %{$c2h{$s}};
  untie %{$c2cc{$s}};
};

sub findHead {
  my ($fr, $cc, $d) = @_;
    
  my $s = (unpack "C", substr ($cc, 0, 1)) % $split;
  my $v1 = defined $c2cc{$s}{$cc} ? substr($c2cc{$s}{$cc}, 0, 20)  : "";
  if ($v1 eq ""){
    my $dp = pack 'w', 0;
    $c2h{$s}{$cc} = $cc.$dp;
    return ($fr, $cc, $d);
  }
  my $s1 = (unpack "C", substr ($v1, 0, 1)) % $split;
  #print "".(toHex($v1)).";".(defined $c2h{$s1}{$v1})."\n";
  if (defined $c2h{$s1}{$v1}){
    my $res = $c2h{$s1}{$v1};
    my $h = substr($res, 0, 20);
    my $d1 = unpack "w", substr($res, 20, length($res) - 20);
    #print "--$fr;".(toHex($v1)).";".(toHex($h)).";d+d1=".($d+$d1).";d1=$d1\n";
    my $dp = pack 'w', $d1+1;
    $c2h{$s}{$cc} = $h.$dp;
    return ($fr, $h, $d1+$d+1);
  }
  
  #print "- $fr;".(toHex($cc)).";".(toHex($v1)).";$d\n";
  my ($fr1, $h, $d1) = findHead ($fr, $v1, $d+1);
  #print "+ $fr1;".(toHex($cc)).";".(toHex($v1)).";$d;$d1\n";
  if (!defined ($c2h{$s}{$cc})){
    my $dp = pack 'w', $d1-$d;
    $c2h{$s}{$cc} = $h.$dp;
  }
  ($fr1, $h, $d1);
}



