#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");

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

my $debug = 0;
my $sections = 128;

my $type = $ARGV[0];
my $sec = $ARGV[1];

my $fbase="/fast/All.sha1/sha1.${type}_new_";
my $fbasei ="/data/All.blobs/${type}_";


my (%fhos, %fhoi);
tie %fhos, "TokyoCabinet::HDB", "${fbase}$sec.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT
  , 16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
#  , 37777217, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fbase$sec.tch\n";
open INI, "$fbasei$sec.idx" or die ($!);
while (<INI>){
  chop();
  my ($n, $offset, $siz, $hsha1Full, @x) = split(/\;/, $_, -1);
  $hsha1Full = $x[0] if ($#x > 0);
  my $sha1Full = fromHex ($hsha1Full);
  $fhos{$sha1Full} = pack "w", $n;
}
  
untie %fhos;

