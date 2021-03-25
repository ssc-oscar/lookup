#!/usr/bin/perl
use lib ("$ENV{HOME}/lookup", "$ENV{HOME}/lib64/perl5", "/home/audris/lib64/perl5","$ENV{HOME}/lib/perl5", "$ENV{HOME}/lib/x86_64-linux-gnu/perl", "$ENV{HOME}/share/perl5");
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

my $sections = 128;

my $type = $ARGV[0];
my $fbasei = "/data/All.blobs/${type}_";
my $fbase="All.sha1c/${type}_";

my (%fhos);
my $sec = $ARGV[1];
my $pre = "/fast";
tie %{$fhos{$sec}}, "TokyoCabinet::HDB", "$pre/${fbase}$sec.tch", TokyoCabinet::HDB::OWRITER | TokyoCabinet::HDB::OCREAT,
   16777213, -1, -1, TokyoCabinet::TDB::TLARGE, 100000
    or die "cant open $pre/$fbase$sec.tch\n";  
open (FD, "$fbasei$sec.bin") or die "$!";
binmode(FD);
open A, "$fbasei$sec.idx" or die ($!);
my $count = 0;
while (<A>){
  chop ();
  my ($nn, $of, $len, $hash) = split (/\;/, $_, -1);
  my $h = fromHex ($hash);
  seek (FD, $of, 0);
  my $codeC = "";
  my $rl = read (FD, $codeC, $len);
  $fhos{$sec}{$h} = $codeC;
  $count ++;
}
print "$count ${type}s added\n";
untie %{$fhos{$sec}};
