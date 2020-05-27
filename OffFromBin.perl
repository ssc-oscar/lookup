#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl");

use strict;
use warnings;
use Error qw(:try);

use TokyoCabinet;

sub toHex { 
  return unpack "H*", $_[0]; 
} 

sub fromHex { 
  return pack "H*", $_[0]; 
} 

my $output = $ARGV[0];

my %dat;
tie %dat, "TokyoCabinet::HDB", "$output", TokyoCabinet::HDB::OWRITER | 
     TokyoCabinet::HDB::OCREAT, 16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
        or die "cant open $output\n";

while (<STDIN>){
  chop();
  my ($n, $offset, $siz, $sec, $hsha, @p) = split(/\;/, $_, -1);
  my $sha = fromHex ($hsha);
  $data{$sha} = pack "w", $n;
}

untie %data;


