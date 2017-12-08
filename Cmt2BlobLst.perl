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

sub safeDecomp {
  my ($codeC, $n) = @_;
  try {
    my $code = decompress ($codeC);
    return $code;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex; $n\n";
    return "";
  }
}


my $detail = 0;
$detail = $ARGV[1] if defined $ARGV[1];

my %p2c;
tie %p2c, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";

while (my ($p, $v) = each %p2c){
  list ($p, $v);
}
untie %p2c;


sub list {
  my ($c, $v) = @_;
  my $ns = length($v)/20;
  my $c1 = toHex($c);
  print "$c1;$ns";
  if ($detail){
    for my $i (0..($ns-1)){
      my $c0 = substr ($v, 20*$i, 20);
      print ";".(toHex($c0));
    }
  }
  print "\n";
}



