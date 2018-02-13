#!/usr/bin/perl -I /home/audris/lib64/perl5

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
my $parts = 2;

my $type = $ARGV[0];
my $sec = $ARGV[1];

my $fbase="/data/All.sha1/sha1.${type}_";
my $fbasei ="/data/All.blobs/${type}_";


my (%fhos, %fhoi);
tie %fhos, "TokyoCabinet::HDB", "${fbase}$sec.tch", TokyoCabinet::HDB::OWRITER |
   TokyoCabinet::HDB::OCREAT, 16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
      or die "cant open $fbase$sec.tch\n";
open INI, "$fbasei$sec.idx" or die ($!);
while (<INI>){
  chop();
  my ($n, $offset, $siz, $hsha1Full) = split(/\;/, $_, -1);
  my $sha1Full = fromHex ($hsha1Full);
  $fhos{$sha1Full} = pack "w", $n;
}
  
untie %fhos;

