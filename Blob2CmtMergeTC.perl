#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

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

my %b2cI1;
tie %b2cI1, "TokyoCabinet::HDB", "$ARGV[0]", TokyoCabinet::HDB::OREADER,   
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[0]\n";

my %b2cI2;
tie %b2cI2, "TokyoCabinet::HDB", "$ARGV[1]", TokyoCabinet::HDB::OREADER,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[1]\n";

my %b2cO;
tie %b2cO, "TokyoCabinet::HDB", "$ARGV[2]", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
        16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
     or die "cant open $ARGV[1]\n";


my %found = ();
while (my ($k, $v) = each %b2cI1){
  if (defined $b2cI2{$k}){
    $found{$k}++;
    $v = merge ($v, $b2cI2{$k});
  }
  $b2cO{$k} = $v;
}
while (my ($k, $v) = each %b2cI2){
  if (!defined $found{$k}){
    $b2cO{$k} = $v;
  }
}

sub merge {
  my ($v0, $v1) = @_;
  my $ns0 = length($v0)/20;
  my $ns1 = length($v1)/20;
  my %sa = ();
  for my $i (0..($ns0-1)){
    $sa{(substr ($v0, 20*$i, 20))}++;
  }
  for my $i (0..($ns1-1)){
    $sa{(substr ($v1, 20*$i, 20))}++;
  }
  return join '', (sort keys %sa);
}


untie %b2cO;
untie %b2cI1;
untie %b2cI2;

