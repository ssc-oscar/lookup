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

my $outN = $ARGV[1];
my $sec;
my $nParts = 8;
my $doPart = -1;
if (defined $ARGV[2]){
  $nParts = $ARGV[2]+0 if defined $ARGV[2];
  $doPart = $ARGV[3]+0 if defined $ARGV[3];
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
     my $s = (unpack "C", substr ($p, 0, 1))%$nParts;
     next  if $doPart >= 0 && $s != $doPart;
	  $p2c{$s}{$p}{$c}++;
  }
  $lines ++;
  print STDERR "$lines done\n" if (!($lines%100000000)); 
}
untie %c2p;

for $sec (0..($nParts-1)){
  next if $doPart >= 0 && $sec != $doPart;
  my $fname = "$outN.$sec.tch";
  $fname = "$outN" if ($nParts == 1);
  my %out;
  tie %out, "TokyoCabinet::HDB", "$fname", TokyoCabinet::HDB::OWRITER |  TokyoCabinet::HDB::OCREAT,
    16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
    or die "cant open $fname\n";
  while (my ($k, $v) = each %{$p2c{$sec}}){
    my $vO = join '', sort keys %{$v};
    $out{$k} = $v0;
  }
  untie %out;
}


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

