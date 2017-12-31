#!/usr/bin/perl -I /home/audris/lib64/perl5
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


my %p2c;
tie %p2c, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";

my %p2c2;
tie %p2c2, "TokyoCabinet::HDB", "$ARGV[1]", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";

my (%fix, %bad);
while (<STDIN>){
  chop();
  my ($p, $pc) = split (/\;/, $_, -1);
  $fix{$pc}{$p}++;
  $bad{$p}++ if $p ne $pc;
}

my %vres;
while (my ($k, $v) = each %fix){
  my %tmp = ();
  for my $p (keys %{$v}, $k){
    my $v1 = $p2c{$p};
    my $ns = length($v1)/20;
    for my $i (0..($ns-1)){
      my $c = substr ($v, 20*$i, 20);
      $tmp{$c}++;
    }
  }
  $vres{$k} = join '', keys %tmp;
}

while (my ($k, $v) = each %p2c){
  if (defined $vres{$k}){
    
    $p2c2{$p} = $vres{$k};
  }else{ 
    if (! defined $bad{$k}){
      $p2c2{$p} = $v;
    }
  }
} 

untie %p2c;
untie %p2c2;


