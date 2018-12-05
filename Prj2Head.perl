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


my $detail = 0;
$detail = $ARGV[1]+0 if defined $ARGV[1];
my $split = 32;
$split = $ARGV[2] + 0 if defined $ARGV[2];

my (%p2c, %c2cc);
for my $sec (0..($split-1)){
  my $fname = "$ARGV[0].$sec.tch";
  $fname = $ARGV[0] if ($split == 1);
  tie %{$p2c{$sec}}, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fname\n";


for my $sec (0..($split-1)){
  tie %{$c2cc{$sec}}, "TokyoCabinet::HDB", "/data/basemaps/c2cc.$sec.tch", TokyoCabinet::HDB::OREADER,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open /da4_data/basemaps/c2cc.$sec.tch\n";
}

my $fname = $ARGV[0];
tie %p2c, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OREADER,
   16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
   or die "cant open $fname\n";


while (my ($p, $v) = each %p2c){
  my $ns = length($v)/20;
  my %tmp = ();
  for my $i (0..($ns-1)){
    my $c = substr ($v, 20*$i, 20);
    my $s = (unpack "C", substr ($c, 0, 1))%$split;
    next if defined $c2cc{$s}{$c};
    $tmp{$c}++;
  }
  my @t = keys %tmp;
  print "$p;".($#t+1);
  for my $h (@t){
    print ";".(toHex($h));
  }
  print "\n";
}


untie %p2c;
for my $sec (0..($split-1)){
  untie %{$c2cc{$sec}};
}

