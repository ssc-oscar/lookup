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

my (%c2h, %c2pc);
my $sec = $ARGV[1];

my $fname = "$ARGV[0]";
tie %{$c2h{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
    16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
    or die "cant open $fname\n";

for my $s (0..($split-1)){ 
  tie %{$c2pc{$s}}, "TokyoCabinet::HDB", "/fast/c2pcO.$s.tch", TokyoCabinet::HDB::OREADER,
      16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open /da4_data/basemaps/c2pcO.$s.tch\n";
}

my $i = 0;
while (my ($c, $v) = each %{$c2pc{$sec}}){
  my $h = findHead ($v);
  $c2h{$sec}{$c} = $h;
  #print "".(toHex($c)).";".(toHex ($h))."\n";
  #$i += 1;
  #last if $i > 5;
}

untie %{$c2h{$sec}};
for my $s (0..($split-1)){ untie %{$c2pc{$s}} };

sub findHead {
  my $v = $_[0];
  my $n = length ($v)/20;
  for my $i (0..($n-1)){
    my $pc = substr ($v, ($n-1)*20, 20); 
    my $s = (unpack "C", substr ($pc, 0, 1)) % $split;
    my $v1 = defined $c2pc{$s}{$pc} ? $c2pc{$s}{$pc} : "";
    return $pc if $v1 eq "";
    return findHead ($v1);
  }
}


