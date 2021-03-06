#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
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
BEGIN { $SIG{'__WARN__'} = sub { if (0) { print STDERR $_[0] } } };

my $split = 32;

my (%c2r, %c2pc);
my $sec = $ARGV[0];
my $ver = $ARGV[1];
for my $s (0..($split-1)){ 
  tie %{$c2r{$s}}, "TokyoCabinet::HDB", "/fast/c2rFull$ver.$s.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
    16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
    or die "cant open /fast/c2rFull$ver.$s.tch\n";
  tie %{$c2pc{$s}}, "TokyoCabinet::HDB", "/fast/c2pcFull$ver.$s.tch", TokyoCabinet::HDB::OREADER| TokyoCabinet::HDB::ONOLCK,
      16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open /fast/c2pcFull$ver.$s.tch\n";
}

my $line = 0;
my $mdepth = 0;
my $nlook = 0;
open A, 'cut -d\; -f4'." /data/All.blobs/commit_$sec.idx /data/All.blobs/commit_".($sec+32).".idx /data/All.blobs/commit_".($sec+64).".idx /data/All.blobs/commit_".($sec+96).".idx|"; 
#open A, 'cut -d\; -f4'." /data/All.blobs/commit_$sec.idx|";
while (<A>){
  chop();
  my $ch = $_;
  my $c = fromHex ($ch);
  my $s = (unpack "C", substr ($c, 0, 1)) % $split;
  $nlook ++;
  if (defined $c2r{$s}{$c}){
     #my $res = $c2r{$s}{$c};
     #my $r = substr($res, 0, 20);
     #my $d1 = unpack "w", substr($res, 20, length($res) - 20);
     #print "F;$ch;".(toHex($r)).";$d1\n";
  }else{
    if (defined $c2pc{$s}{$c}){
      my $v = substr($c2pc{$s}{$c}, 0, 20);
      my ($ch, $r, $d) = findHead ($ch, $v, 1);
      my $dp = pack 'w', $d;
      $c2r{$s}{$c} = $r.$dp;
      $mdepth = $d if $d > $mdepth;
      print "F:$ch;".(toHex($v)).";".(toHex($r)).";$d;nlooked=$nlook;ncalc=$line;mdepth=$mdepth\n" if !(($line++)%500000);
    }else{
      print "c2pc not defined for:$ch;$s\n;"
    }
  }
}
print "looked=$nlook;calculated=$line;maxdep=$mdepth\n";

for my $s (0..($split-1)){ 
  untie %{$c2r{$s}};
  untie %{$c2pc{$s}};
};

sub findHead {
  my ($fr, $pc, $d) = @_;
    
  my $s = (unpack "C", substr ($pc, 0, 1)) % $split;
  my $v1 = defined $c2pc{$s}{$pc} ? substr($c2pc{$s}{$pc}, 0, 20)  : "";
  if ($v1 eq ""){
    my $dp = pack 'w', 0;
    $c2r{$s}{$pc} = $pc.$dp;
    return ($fr, $pc, $d);
  }
  my $s1 = (unpack "C", substr ($v1, 0, 1)) % $split;
  #print "".(toHex($v1)).";".(defined $c2h{$s1}{$v1})."\n";
  if (defined $c2r{$s1}{$v1}){
    my $res = $c2r{$s1}{$v1};
    my $r = substr($res, 0, 20);
    my $d1 = unpack "w", substr($res, 20, length($res) - 20);
    #print "--$fr;".(toHex($v1)).";".(toHex($r)).";d+d1=".($d+$d1).";d1=$d1\n";
    my $dp = pack 'w', $d1+1;
    $c2r{$s}{$pc} = $r.$dp;
    return ($fr, $r, $d1+$d+1);
  }
  
  #print "- $fr;".(toHex($pc)).";".(toHex($v1)).";$d\n";
  my ($fr1, $r, $d1) = findHead ($fr, $v1, $d+1);
  #print "+ $fr1;".(toHex($pc)).";".(toHex($v1)).";$d;$d1\n";
  if (!defined ($c2r{$s}{$pc})){
    my $dp = pack 'w', $d1-$d;
    $c2r{$s}{$pc} = $r.$dp;
  }
  ($fr1, $r, $d1);
}



