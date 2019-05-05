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

my (%c2r, %c2pc);
my $sec = $ARGV[0];

for my $s (0..($split-1)){
   tie %{$c2r{$s}}, "TokyoCabinet::HDB", "/fast/c2rFullO.$s.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
    16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
    or die "cant open /fast/c2rFullO.$s.tch\n";
}

for my $s (0..($split-1)){ 
  tie %{$c2pc{$s}}, "TokyoCabinet::HDB", "/fast/c2pcFullO.$s.tch", TokyoCabinet::HDB::OREADER,
      16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open /da4_data/basemaps/c2pcFullO.$s.tch\n";
}

while (my ($c, $v) = each %{$c2pc{$sec}}){
  if (!defined $c2r{$sec}{$c}){
    my ($r, $d) = findRoot ($v, 0);
    my $pd = pack 'w', $d;
    $c2r{$sec}{$c} = $r.$pd;
  }
}

untie %{$c2r{$sec}};
for my $s (0..($split-1)){ untie %{$c2pc{$s}} };

sub findRoot {
  my ($v, $d) = @_;
  #my $n = length ($v)/20;
  #for my $i (0..($n-1)){
  my $i = 0;
  {
    my $pc = substr ($v, $i*20, 20); 
    my $s = (unpack "C", substr ($pc, 0, 1)) % $split;
    my $v1 = defined $c2pc{$s}{$pc} ? $c2pc{$s}{$pc} : "";
    if ($v1 eq ""){
      my $dp = pack 'w', 0;
      $c2r{$s}{$pc} = $pc.$dp;
      return ($pc, $d);
    }
    if (defined $c2r{$s}{$v1}){
      return ($c2r{$s}{$v1}, $d);
    }
    my ($r, $d) = findRoot ($v1, $d+1);
    my $pd = pack 'w', $d;
    $c2r{$s}{$pc} = $r . $pd;
    return ($r, $d);
  }
}


