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
  tie %{$c2cc{$s}}, "TokyoCabinet::HDB", "/fast/c2ccFullO.$s.tch", TokyoCabinet::HDB::OREADER,
      16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open /fast/c2ccFullO.$s.tch\n";
}

while (<STDIN>){
  chop();
  my $ch = $_;
  my $c = fromHex ($ch);
  my $s = (unpack "C", substr ($c, 0, 1)) % $split;
  if (defined $c2h{$s}{$c}){
     my $res = $c2h{$s}{$c};
     my $h = substr($res, 0, 20);
     my $d1 = unpack "w", substr($res, 20, length($res) - 20);
     print "F;$ch;".(toHex($h)).";$d1\n";
  }else{
    if (defined $c2cc{$s}{$c}){
      my $v = substr($c2cc{$s}{$c}, 0, 20);
      my ($ch, $h, $d) = findHead ($ch, $v, 1);
      my $dp = pack 'w', $d;
      $c2h{$s}{$c} = $h.$dp;
      print "F:$ch;".(toHex($v)).";".(toHex($h)).";$d\n";
    }else{
      print "F:$ch;$ch;$ch;0\n;"
    }
  }
}

for my $s (0..($split-1)){ 
  untie %{$c2cc{$s}};
};

for my $s (0..($split-1)){
  for my $c (keys %{$c2h{$s}}){
    my $res = $c2h{$s}{$c};
    my $h = toHex(substr($res, 0, 20));
    my $d1 = unpack "w", substr($res, 20, length($res) - 20);
    print "".(toHex($c)).";$h;$d1\n";
  }
}

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



