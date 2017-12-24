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


my %c2p;
my %p2c;
my $lines = 0;
tie %c2p, "TokyoCabinet::HDB", $ARGV[0], TokyoCabinet::HDB::OREADER,
   16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
  or die "cant open $ARGV[0]\n";

while (my ($c, $v) = each %c2p){
  my @ps = split(/\;/, safeDecomp($v), -1);
  for my $p (@ps){
	  $p2c{$p}{$c}++;
  }
  $lines ++;
  print STDERR "$lines done\n" if (!($lines%100000000)); 
}
untie %c2p;

sub safeComp {
  my $code = $_[0];
  try {
    my $codeC = compress ($code);
    return $codeC;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex\n$code\n";
    return "";
  }
}

sub safeDecomp {
  my $code = $_[0];
  try {
    my $codeC = decompress ($code);
    return $codeC;
  } catch Error with {
    my $ex = shift;
    print STDERR "Error: $ex\n$code\n";
    return "";
  }
}

print STDERR "writing $lines\n";
$lines = 0;
outputTC ($ARGV[1]);


sub outputTC {
  my $n = $_[0];
  my %p2c1;
  tie %p2c1, "TokyoCabinet::HDB", $n, TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
     16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $n\n";
  while (my ($p, $v) = each %p2c){
    $lines ++;
    print STDERR "$lines done out\n" if (!($lines%100000000));
    my $cs = join '', sort keys %{$v};
    $p2c1{$p} = $cs;
  }
  untie %p2c1;
}



