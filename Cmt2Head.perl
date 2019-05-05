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


my $split = 32;

my (%c2h, %c2cc);
my $sec = $ARGV[0];

for my $s (0..($split-1)){
  tie %{$c2h{$sec}}, "TokyoCabinet::HDB", "/fast/c2hFullO.$s.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
    16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
    or die "cant open /fast/c2hFullO.$s.tch\n";
}

for my $s (0..($split-1)){ 
  tie %{$c2cc{$s}}, "TokyoCabinet::HDB", "/fast/c2ccFullO.$s.tch", TokyoCabinet::HDB::OREADER,
      16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open /fast/c2ccFullO.$s.tch\n";
}

my $i = 0;
while (my ($c, $v) = each %{$c2cc{$sec}}){
  if (!defined $c2h{$sec}{$c}){
    my ($ch, $h, $d) = findHead (toHex ($c), $v, 0);
    my $pd = pack 'w', $d;
    $c2h{$sec}{$c} = $h.$pd;
    print "$ch;".(toHex ($h)).";depth=$d\n";
  }
}

for my $s (0..($split-1)){ 
  untie %{$c2h{$s}};
  untie %{$c2cc{$s}} 
};

sub findHead {
  my ($fr, $v, $d) = @_;
  my $n = length ($v)/20;
  #for my $i (0..($n-1)){
  my $i = 0;
  my $cc = substr ($v, $i*20, 20); 
    
  my $s = (unpack "C", substr ($cc, 0, 1)) % $split;
  my $v1 = defined $c2cc{$s}{$cc} ? $c2cc{$s}{$cc} : "";
  if ($v1 eq ""){
    my $dp = pack 'w', 0;
    $c2h{$s}{$cc} = $cc.$dp;
    return ($fr, $cc, $d);
  }
  if (defined $c2h{$s}{$v1}){
    my $d1 = unpack "w", substr($c2h{$s}{$v1},20,length($c2h{$s}{$v1})-20);
    return ($fr, substr($c2h{$s}{$v1}, 0,20), $d1+$d);
  }
  print "$fr at $d\n" if !(($d+1)%1000000);
  my $h = "";
  ($fr, $h, $d) = findHead ($fr, $v1, $d+1);
  my $pd = pack 'w', $d;
  $c2h{$s}{$cc} = $h . $pd;
  return ($fr, $h, $d);
}


