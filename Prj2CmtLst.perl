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
$detail = $ARGV[1];

my %p2c;
tie %p2c, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";

while (my ($p, $v) = each %p2c){
  list ($p, $v);
}
untie %p2c;


sub list {
  my ($p, $v) = @_;
  my $ns = length($v)/20;
  my %tmp = ();
  #$p =~ s/\n$//;
  #my $sec = (unpack "C", substr ($p, 0, 1))%8;
  #print "$sec;$p;$ns";
  print "$p;$ns";
  if ($detail){
    for my $i (0..($ns-1)){
      my $c = substr ($v, 20*$i, 20);
      print ";".(toHex($c));
    }
  }
  print "\n";
}


